import { NextResponse } from "next/server";
import { z } from "zod";
import {
  getMonitorByToken,
  reportCheckForMonitor,
} from "@/lib/monitors";

export const dynamic = "force-dynamic";

function authorized(request: Request) {
  const secret = process.env.CRON_SECRET;
  if (!secret) {
    return process.env.NODE_ENV !== "production";
  }
  return request.headers.get("authorization") === `Bearer ${secret}`;
}

const bodySchema = z.object({
  token: z.string().min(1),
  ok: z.boolean(),
  statusCode: z.number().nullable(),
  error: z.string().nullable(),
  latencyMs: z.number().nonnegative().default(0),
});

/** Python worker reports each GET probe so the website stays accurate. */
export async function POST(request: Request) {
  if (!authorized(request)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const json = await request.json().catch(() => null);
  const parsed = bodySchema.safeParse(json);
  if (!parsed.success) {
    return NextResponse.json({ error: "Invalid body" }, { status: 400 });
  }

  const monitor = await getMonitorByToken(parsed.data.token);
  if (!monitor) {
    return NextResponse.json({ error: "Monitor not found" }, { status: 404 });
  }

  const result = await reportCheckForMonitor(monitor, {
    ok: parsed.data.ok,
    statusCode: parsed.data.statusCode,
    error: parsed.data.error,
    latencyMs: parsed.data.latencyMs,
  });

  return NextResponse.json({ ok: true, result });
}
