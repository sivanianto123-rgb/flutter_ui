#!/usr/bin/env python3
"""
PulsePing continuous monitor — the classic forever loop:

  1. Start / wake after waiting
  2. GET each watched URL (requests)
  3. 200–399 → up; timeout / connection error / bad status → down
  4a. If up → do nothing
  4b. If down → email alert (smtplib) + sync status to the website
  5. Sleep CHECK_INTERVAL seconds
  6. Repeat forever

Run (with the Next.js app up so status stays accurate on the site):

  pip install -r worker/requirements.txt
  python worker/monitor.py

Env (optional — falls back to .env.local / defaults):
  APP_URL=http://localhost:3000
  CRON_SECRET=dev-cron-secret-change-me
  CHECK_INTERVAL=60          # seconds between full sweeps (realtime-ish)
  REQUEST_TIMEOUT=10

  # Direct SMTP alerts from this worker (optional; app can also email via Resend)
  SMTP_HOST=smtp.gmail.com
  SMTP_PORT=587
  SMTP_USER=you@gmail.com
  SMTP_PASS=your-app-password
  SMTP_FROM=PulsePing <you@gmail.com>
"""

from __future__ import annotations

import json
import os
import smtplib
import ssl
import sys
import time
from email.message import EmailMessage
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

try:
    import requests
except ImportError:
    print("Install deps first: pip install -r worker/requirements.txt", file=sys.stderr)
    raise


ROOT = Path(__file__).resolve().parents[1]


def load_dotenv_file(path: Path) -> None:
    if not path.exists():
        return
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        os.environ.setdefault(key, value)


load_dotenv_file(ROOT / ".env.local")
load_dotenv_file(ROOT / ".env")

APP_URL = os.getenv("APP_URL") or os.getenv("NEXT_PUBLIC_APP_URL") or "http://localhost:3000"
APP_URL = APP_URL.rstrip("/")
CRON_SECRET = os.getenv("CRON_SECRET") or "dev-cron-secret-change-me"
CHECK_INTERVAL = int(os.getenv("CHECK_INTERVAL") or "60")
REQUEST_TIMEOUT = int(os.getenv("REQUEST_TIMEOUT") or "10")

# Standalone single-site mode (no website API required)
STANDALONE_URL = os.getenv("MONITOR_URL")
STANDALONE_EMAIL = os.getenv("ALERT_EMAIL")


def api_headers() -> dict[str, str]:
    return {
        "Authorization": f"Bearer {CRON_SECRET}",
        "Content-Type": "application/json",
        "User-Agent": "PulsePing-Worker/1.0",
    }


def api_get(path: str) -> Any:
    req = Request(f"{APP_URL}{path}", headers=api_headers(), method="GET")
    with urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def api_post(path: str, payload: dict[str, Any]) -> Any:
    data = json.dumps(payload).encode("utf-8")
    req = Request(f"{APP_URL}{path}", data=data, headers=api_headers(), method="POST")
    with urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def probe(url: str) -> dict[str, Any]:
    """Step 2–3: GET the site and decide up vs down."""
    started = time.time()
    try:
        response = requests.get(
            url,
            timeout=REQUEST_TIMEOUT,
            allow_redirects=True,
            headers={"User-Agent": "PulsePing/1.0 (+uptime-monitor)"},
        )
        latency_ms = int((time.time() - started) * 1000)
        ok = 200 <= response.status_code < 400
        return {
            "ok": ok,
            "statusCode": response.status_code,
            "error": None if ok else f"HTTP {response.status_code}",
            "latencyMs": latency_ms,
        }
    except requests.Timeout:
        return {
            "ok": False,
            "statusCode": None,
            "error": f"Timed out after {REQUEST_TIMEOUT}s",
            "latencyMs": int((time.time() - started) * 1000),
        }
    except requests.RequestException as exc:
        return {
            "ok": False,
            "statusCode": None,
            "error": str(exc) or "Request failed",
            "latencyMs": int((time.time() - started) * 1000),
        }


def smtp_configured() -> bool:
    return bool(os.getenv("SMTP_HOST") and os.getenv("SMTP_USER") and os.getenv("SMTP_PASS"))


def send_email(to: str, subject: str, body: str) -> None:
    """Step 4b: email alert via smtplib when the site is down."""
    if not smtp_configured():
        print(f"[email skipped — set SMTP_*] To={to} Subject={subject}")
        print(body)
        print()
        return

    host = os.environ["SMTP_HOST"]
    port = int(os.getenv("SMTP_PORT") or "587")
    user = os.environ["SMTP_USER"]
    password = os.environ["SMTP_PASS"]
    from_addr = os.getenv("SMTP_FROM") or user

    msg = EmailMessage()
    msg["From"] = from_addr
    msg["To"] = to
    msg["Subject"] = subject
    msg.set_content(body)

    context = ssl.create_default_context()
    with smtplib.SMTP(host, port, timeout=30) as server:
        server.starttls(context=context)
        server.login(user, password)
        server.send_message(msg)
    print(f"[email sent] To={to} Subject={subject}")


# Track last known status in this process so we only alert on transitions
_last_status: dict[str, str] = {}


def handle_result(key: str, url: str, email: str, result: dict[str, Any], token: str | None) -> None:
    status = "up" if result["ok"] else "down"
    previous = _last_status.get(key)
    _last_status[key] = status

    stamp = time.strftime("%H:%M:%S")
    detail = result["statusCode"] if result["ok"] else result["error"]
    print(f"[{stamp}] {url} → {status.upper()} ({detail}, {result['latencyMs']}ms)")

    # Sync accurate status to the website immediately
    if token:
        try:
            api_post(
                "/api/internal/report",
                {
                    "token": token,
                    "ok": result["ok"],
                    "statusCode": result["statusCode"],
                    "error": result["error"],
                    "latencyMs": result["latencyMs"],
                },
            )
        except (HTTPError, URLError, TimeoutError, json.JSONDecodeError) as exc:
            print(f"  ! failed to sync website status: {exc}")

    # 4a. up → do nothing
    # 4b. down → email on transition
    # App mode: website API sends the alert (Resend) when we sync.
    # Standalone mode: this worker emails via smtplib.
    if token is None and status == "down" and previous != "down":
        send_email(
            email,
            f"DOWN — {url}",
            f"PulsePing detected downtime.\n\nURL: {url}\nDetail: {result['error'] or result['statusCode']}\n",
        )


def fetch_monitors() -> list[dict[str, Any]]:
    data = api_get("/api/internal/monitors")
    return list(data.get("monitors") or [])


def run_once() -> None:
    if STANDALONE_URL and STANDALONE_EMAIL:
        result = probe(STANDALONE_URL)
        handle_result("standalone", STANDALONE_URL, STANDALONE_EMAIL, result, token=None)
        return

    try:
        monitors = fetch_monitors()
    except (HTTPError, URLError, TimeoutError, json.JSONDecodeError) as exc:
        print(f"Could not load monitors from {APP_URL}: {exc}")
        print("Is `npm run dev` running? Or set MONITOR_URL + ALERT_EMAIL for standalone mode.")
        return

    if not monitors:
        print("No monitors yet — add one at the website, then this loop will pick it up.")
        return

    for monitor in monitors:
        result = probe(monitor["url"])
        handle_result(
            monitor["token"],
            monitor["url"],
            monitor["email"],
            result,
            token=monitor["token"],
        )


def main() -> None:
    print("PulsePing worker started")
    print(f"  app:      {APP_URL}")
    print(f"  interval: {CHECK_INTERVAL}s")
    print(f"  timeout:  {REQUEST_TIMEOUT}s")
    print(f"  smtp:     {'yes' if smtp_configured() else 'no (console only / app Resend)'}")
    print("Loop: GET → up/down → email if down → sleep → repeat forever\n")

    while True:
        # 1. Start / wake
        run_once()
        # 5. Sleep, then 6. Repeat
        time.sleep(CHECK_INTERVAL)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nStopped.")
