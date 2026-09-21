import { NextResponse } from "next/server";
import { z } from "zod";
import { createMonitor } from "@/lib/monitors";

const bodySchema = z.object({
  url: z.string().min(1).max(2048),
  email: z.string().email().max(320),
});

export async function POST(request: Request) {
  try {
    const json = await request.json();
    const parsed = bodySchema.safeParse(json);

    if (!parsed.success) {
      return NextResponse.json(
        { error: "Enter a valid website URL and email." },
        { status: 400 },
      );
    }

    const monitor = await createMonitor(parsed.data);
    return NextResponse.json({
      ok: true,
      token: monitor.token,
      url: monitor.url,
      status: monitor.status,
      managePath: `/m/${monitor.token}`,
    });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Could not create monitor";
    return NextResponse.json({ error: message }, { status: 400 });
  }
}
