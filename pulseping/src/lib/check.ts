export type CheckResult = {
  ok: boolean;
  statusCode: number | null;
  error: string | null;
  latencyMs: number;
};

const TIMEOUT_MS = 10_000;

/**
 * Step 2–3 of the monitor loop:
 * GET the URL → 200–399 means up, anything else / network error means down.
 */
export async function checkUrl(url: string): Promise<CheckResult> {
  const started = Date.now();
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS);

  try {
    const response = await fetch(url, {
      method: "GET",
      redirect: "follow",
      signal: controller.signal,
      headers: {
        "User-Agent": "PulsePing/1.0 (+uptime-monitor)",
        Accept: "*/*",
      },
      cache: "no-store",
    });

    const latencyMs = Date.now() - started;
    // Match classic monitor: HTTP 200 (and other success/redirect) → up
    const ok = response.status >= 200 && response.status < 400;

    return {
      ok,
      statusCode: response.status,
      error: ok ? null : `HTTP ${response.status}`,
      latencyMs,
    };
  } catch (error) {
    const latencyMs = Date.now() - started;
    const message =
      error instanceof Error
        ? error.name === "AbortError"
          ? "Timed out after 10s"
          : error.message
        : "Request failed";

    return {
      ok: false,
      statusCode: null,
      error: message,
      latencyMs,
    };
  } finally {
    clearTimeout(timeout);
  }
}
