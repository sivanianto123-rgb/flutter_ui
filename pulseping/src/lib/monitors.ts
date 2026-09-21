import { eq } from "drizzle-orm";
import { nanoid } from "nanoid";
import { getDb } from "@/db";
import { monitors, type Monitor } from "@/db/schema";
import { checkUrl, type CheckResult } from "@/lib/check";
import {
  sendDownAlert,
  sendRecoveredAlert,
  sendWelcomeEmail,
} from "@/lib/email";
import { normalizeUrl } from "@/lib/url";

/**
 * Classic monitor loop semantics (per check):
 * 1. GET the URL
 * 2. 2xx/3xx → up (no alert)
 * 3. error / bad status → down → email only on transition to down
 * Status is written immediately so the website stays accurate.
 */
export async function createMonitor(input: {
  url: string;
  email: string;
}) {
  const url = normalizeUrl(input.url);
  const email = input.email.trim().toLowerCase();
  const id = nanoid(12);
  const token = nanoid(24);
  const now = Date.now();

  const result = await checkUrl(url);
  const status = result.ok ? "up" : "down";

  const db = await getDb();
  await db.insert(monitors).values({
    id,
    url,
    email,
    token,
    status,
    lastCheckedAt: now,
    lastStatusCode: result.statusCode,
    lastError: result.error,
    consecutiveFailures: result.ok ? 0 : 1,
    createdAt: now,
  });

  await sendWelcomeEmail({ to: email, url, token, status });

  if (!result.ok) {
    await sendDownAlert({
      to: email,
      url,
      token,
      error: result.error,
      statusCode: result.statusCode,
    });
  }

  return { id, token, url, email, status, latencyMs: result.latencyMs };
}

export async function listMonitors() {
  const db = await getDb();
  return db.select().from(monitors);
}

export async function getMonitorByToken(token: string) {
  const db = await getDb();
  const rows = await db
    .select()
    .from(monitors)
    .where(eq(monitors.token, token))
    .limit(1);
  return rows[0] ?? null;
}

export async function deleteMonitorByToken(token: string) {
  const db = await getDb();
  await db.delete(monitors).where(eq(monitors.token, token));
}

async function applyCheckResult(monitor: Monitor, result: CheckResult) {
  const now = Date.now();
  const previousStatus = monitor.status;
  const nextStatus: "up" | "down" = result.ok ? "up" : "down";
  const consecutiveFailures = result.ok ? 0 : monitor.consecutiveFailures + 1;

  const db = await getDb();
  await db
    .update(monitors)
    .set({
      status: nextStatus,
      lastCheckedAt: now,
      lastStatusCode: result.statusCode,
      lastError: result.error,
      consecutiveFailures,
    })
    .where(eq(monitors.id, monitor.id));

  // 4a. up → do nothing (except recovery mail if it was down)
  // 4b. down → email alert (only when state flips, so we don't spam every loop)
  const becameDown = nextStatus === "down" && previousStatus !== "down";
  const recovered = nextStatus === "up" && previousStatus === "down";

  if (becameDown) {
    await sendDownAlert({
      to: monitor.email,
      url: monitor.url,
      token: monitor.token,
      error: result.error,
      statusCode: result.statusCode,
    });
  } else if (recovered) {
    await sendRecoveredAlert({
      to: monitor.email,
      url: monitor.url,
      token: monitor.token,
      statusCode: result.statusCode,
    });
  }

  return {
    id: monitor.id,
    url: monitor.url,
    previousStatus,
    status: nextStatus,
    ...result,
    alerted: becameDown || recovered,
  };
}

export async function runCheckForMonitor(monitor: Monitor) {
  const result = await checkUrl(monitor.url);
  return applyCheckResult(monitor, result);
}

/** Apply an external probe result (e.g. from the Python worker). */
export async function reportCheckForMonitor(
  monitor: Monitor,
  result: CheckResult,
) {
  return applyCheckResult(monitor, result);
}

export async function runAllChecks() {
  const all = await listMonitors();
  const results = [];

  for (const monitor of all) {
    results.push(await runCheckForMonitor(monitor));
  }

  return { checked: results.length, results };
}
