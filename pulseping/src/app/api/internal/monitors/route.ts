import { NextResponse } from "next/server";
import { listMonitors } from "@/lib/monitors";

export const dynamic = "force-dynamic";

function authorized(request: Request) {
  const secret = process.env.CRON_SECRET;
  if (!secret) {
    return process.env.NODE_ENV !== "production";
  }
  return request.headers.get("authorization") === `Bearer ${secret}`;
}

/** Used by the Python forever-loop worker to discover what to ping. */
export async function GET(request: Request) {
  if (!authorized(request)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const all = await listMonitors();
  return NextResponse.json({
    monitors: all.map((m) => ({
      id: m.id,
      token: m.token,
      url: m.url,
      email: m.email,
      status: m.status,
    })),
  });
}
