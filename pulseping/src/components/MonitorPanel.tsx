"use client";

import { useRouter } from "next/navigation";
import { useCallback, useEffect, useRef, useState } from "react";
import { displayHost } from "@/lib/url";

type Props = {
  token: string;
  url: string;
  email: string;
  status: "up" | "down" | "unknown";
  lastCheckedAt: number | null;
  lastStatusCode: number | null;
  lastError: string | null;
};

/** Live re-check while the manage page is open — keeps status accurate. */
const LIVE_CHECK_MS = 30_000;

function formatTime(ts: number | null) {
  if (!ts) return "Not checked yet";
  return new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(ts));
}

function formatRelative(ts: number | null) {
  if (!ts) return "";
  const seconds = Math.max(0, Math.round((Date.now() - ts) / 1000));
  if (seconds < 5) return "just now";
  if (seconds < 60) return `${seconds}s ago`;
  const minutes = Math.round(seconds / 60);
  return `${minutes}m ago`;
}

export function MonitorPanel(props: Props) {
  const router = useRouter();
  const [status, setStatus] = useState(props.status);
  const [lastCheckedAt, setLastCheckedAt] = useState(props.lastCheckedAt);
  const [lastStatusCode, setLastStatusCode] = useState(props.lastStatusCode);
  const [lastError, setLastError] = useState(props.lastError);
  const [latencyMs, setLatencyMs] = useState<number | null>(null);
  const [busy, setBusy] = useState<"check" | "delete" | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [tick, setTick] = useState(0);
  const inFlight = useRef(false);

  const applyResult = useCallback((result: {
    status: "up" | "down" | "unknown";
    statusCode: number | null;
    error: string | null;
    ok: boolean;
    latencyMs: number;
  }) => {
    setStatus(result.status);
    setLastCheckedAt(Date.now());
    setLastStatusCode(result.statusCode);
    setLastError(result.error);
    setLatencyMs(result.latencyMs);
    setMessage(
      result.ok
        ? `Up · ${result.latencyMs}ms`
        : `Down · ${result.error ?? "no response"}`,
    );
  }, []);

  const checkNow = useCallback(async (silent = false) => {
    if (inFlight.current) return;
    inFlight.current = true;
    if (!silent) {
      setBusy("check");
      setMessage(null);
    }
    try {
      const response = await fetch(`/api/monitors/${props.token}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action: "check" }),
      });
      const data = await response.json();
      if (!response.ok) {
        if (!silent) setMessage(data.error ?? "Check failed");
        return;
      }
      applyResult(data.result);
    } catch {
      if (!silent) setMessage("Network error");
    } finally {
      inFlight.current = false;
      if (!silent) setBusy(null);
    }
  }, [applyResult, props.token]);

  // Live loop while this page is open: GET → update status → wait → repeat
  useEffect(() => {
    void checkNow(true);
    const checkId = window.setInterval(() => {
      void checkNow(true);
    }, LIVE_CHECK_MS);
    const tickId = window.setInterval(() => setTick((n) => n + 1), 1000);
    return () => {
      window.clearInterval(checkId);
      window.clearInterval(tickId);
    };
  }, [checkNow]);

  async function remove() {
    if (!confirm("Stop watching this site?")) return;
    setBusy("delete");
    try {
      const response = await fetch(`/api/monitors/${props.token}`, {
        method: "DELETE",
      });
      if (!response.ok) {
        const data = await response.json();
        setMessage(data.error ?? "Could not delete");
        setBusy(null);
        return;
      }
      router.push("/?removed=1");
    } catch {
      setMessage("Network error");
      setBusy(null);
    }
  }

  const host = displayHost(props.url);
  const statusLabel =
    status === "up" ? "Up" : status === "down" ? "Down" : "Checking";

  // tick forces relative time to refresh
  void tick;

  return (
    <div className="monitor-panel">
      <div className={`status-orb status-${status}`} aria-hidden>
        <span />
        <span />
        <span />
      </div>

      <p className="monitor-kicker">Live watch</p>
      <h1 className="monitor-host">{host}</h1>
      <a className="monitor-url" href={props.url} target="_blank" rel="noreferrer">
        {props.url}
      </a>

      <p className={`status-pill status-${status}`}>
        <span className="dot" />
        {statusLabel}
      </p>
      <p className="live-note">
        Re-checks every {LIVE_CHECK_MS / 1000}s
        {lastCheckedAt ? ` · last probe ${formatRelative(lastCheckedAt)}` : ""}
        {latencyMs != null ? ` · ${latencyMs}ms` : ""}
      </p>

      <dl className="monitor-meta">
        <div>
          <dt>Alerts to</dt>
          <dd>{props.email}</dd>
        </div>
        <div>
          <dt>Last checked</dt>
          <dd>{formatTime(lastCheckedAt)}</dd>
        </div>
        <div>
          <dt>Last response</dt>
          <dd>
            {lastStatusCode
              ? `HTTP ${lastStatusCode}`
              : lastError
                ? lastError
                : "—"}
          </dd>
        </div>
      </dl>

      {message ? <p className="monitor-message">{message}</p> : null}

      <div className="monitor-actions">
        <button
          type="button"
          className="cta"
          onClick={() => void checkNow(false)}
          disabled={busy !== null}
        >
          {busy === "check" ? "Checking…" : "Check now"}
        </button>
        <button
          type="button"
          className="ghost"
          onClick={() => void remove()}
          disabled={busy !== null}
        >
          {busy === "delete" ? "Removing…" : "Stop watching"}
        </button>
      </div>
    </div>
  );
}
