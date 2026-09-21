import { NextResponse } from "next/server";
import {
  deleteMonitorByToken,
  getMonitorByToken,
  runCheckForMonitor,
} from "@/lib/monitors";

type Params = { params: Promise<{ token: string }> };

export async function GET(_request: Request, { params }: Params) {
  const { token } = await params;
  const monitor = await getMonitorByToken(token);

  if (!monitor) {
    return NextResponse.json({ error: "Monitor not found" }, { status: 404 });
  }

  return NextResponse.json({
    url: monitor.url,
    email: monitor.email,
    status: monitor.status,
    lastCheckedAt: monitor.lastCheckedAt,
    lastStatusCode: monitor.lastStatusCode,
    lastError: monitor.lastError,
    createdAt: monitor.createdAt,
  });
}

export async function POST(request: Request, { params }: Params) {
  const { token } = await params;
  const monitor = await getMonitorByToken(token);

  if (!monitor) {
    return NextResponse.json({ error: "Monitor not found" }, { status: 404 });
  }

  const body = await request.json().catch(() => ({}));
  if (body?.action !== "check") {
    return NextResponse.json({ error: "Unknown action" }, { status: 400 });
  }

  const result = await runCheckForMonitor(monitor);
  return NextResponse.json({ ok: true, result });
}

export async function DELETE(_request: Request, { params }: Params) {
  const { token } = await params;
  const monitor = await getMonitorByToken(token);

  if (!monitor) {
    return NextResponse.json({ error: "Monitor not found" }, { status: 404 });
  }

  await deleteMonitorByToken(token);
  return NextResponse.json({ ok: true });
}
