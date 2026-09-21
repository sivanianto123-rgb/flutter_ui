import { NextResponse } from "next/server";
import { runAllChecks } from "@/lib/monitors";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

function authorized(request: Request) {
  const secret = process.env.CRON_SECRET;
  if (!secret) {
    // Local/dev convenience: allow if no secret configured
    return process.env.NODE_ENV !== "production";
  }

  const header = request.headers.get("authorization");
  return header === `Bearer ${secret}`;
}

export async function GET(request: Request) {
  if (!authorized(request)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const summary = await runAllChecks();
  return NextResponse.json({
    ok: true,
    checked: summary.checked,
    results: summary.results.map((r) => ({
      id: r.id,
      url: r.url,
      status: r.status,
      previousStatus: r.previousStatus,
      ok: r.ok,
      statusCode: r.statusCode,
      error: r.error,
      latencyMs: r.latencyMs,
      alerted: r.alerted,
    })),
  });
}
