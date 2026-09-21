import { Resend } from "resend";
import { displayHost } from "./url";

function getResend() {
  const key = process.env.RESEND_API_KEY;
  if (!key) return null;
  return new Resend(key);
}

function fromAddress() {
  return process.env.EMAIL_FROM ?? "PulsePing <onboarding@resend.dev>";
}

function appUrl() {
  const explicit = process.env.NEXT_PUBLIC_APP_URL;
  if (explicit) return explicit.replace(/\/$/, "");

  const production = process.env.VERCEL_PROJECT_PRODUCTION_URL;
  if (production) return `https://${production.replace(/\/$/, "")}`;

  const preview = process.env.VERCEL_URL;
  if (preview) return `https://${preview.replace(/\/$/, "")}`;

  return "http://localhost:3000";
}

async function sendEmail(opts: {
  to: string;
  subject: string;
  html: string;
  text: string;
}) {
  const resend = getResend();

  if (!resend) {
    console.log("\n[PulsePing email — RESEND_API_KEY not set]");
    console.log(`To: ${opts.to}`);
    console.log(`Subject: ${opts.subject}`);
    console.log(opts.text);
    console.log("");
    return { ok: true as const, mocked: true };
  }

  const { error } = await resend.emails.send({
    from: fromAddress(),
    to: opts.to,
    subject: opts.subject,
    html: opts.html,
    text: opts.text,
  });

  if (error) {
    console.error("Resend error:", error);
    return { ok: false as const, error };
  }

  return { ok: true as const, mocked: false };
}

function shell(content: string) {
  return `<!DOCTYPE html>
<html>
<body style="margin:0;padding:0;background:#0c1210;font-family:Georgia,'Times New Roman',serif;color:#e8efe9;">
  <div style="max-width:560px;margin:0 auto;padding:40px 24px;">
    <div style="font-family:ui-sans-serif,system-ui,sans-serif;font-size:13px;letter-spacing:0.18em;text-transform:uppercase;color:#6ee7a8;margin-bottom:28px;">PulsePing</div>
    ${content}
    <p style="margin-top:40px;font-family:ui-sans-serif,system-ui,sans-serif;font-size:12px;color:#7a8a7e;">You’re getting this because you set up a monitor on PulsePing.</p>
  </div>
</body>
</html>`;
}

export async function sendWelcomeEmail(opts: {
  to: string;
  url: string;
  token: string;
  status: "up" | "down" | "unknown";
}) {
  const manageUrl = `${appUrl()}/m/${opts.token}`;
  const host = displayHost(opts.url);
  const statusLine =
    opts.status === "up"
      ? `${host} looks up right now.`
      : opts.status === "down"
        ? `${host} looks down right now — we’ll keep watching.`
        : `We’re watching ${host}.`;

  const text = `PulsePing is watching ${opts.url}

${statusLine}

Manage this monitor: ${manageUrl}`;

  return sendEmail({
    to: opts.to,
    subject: `Watching ${host}`,
    text,
    html: shell(`
      <h1 style="font-size:28px;font-weight:400;line-height:1.25;margin:0 0 16px;">We’re watching ${host}</h1>
      <p style="font-family:ui-sans-serif,system-ui,sans-serif;font-size:16px;line-height:1.6;color:#c5d2c8;margin:0 0 24px;">${statusLine} We’ll email you if it goes down.</p>
      <a href="${manageUrl}" style="display:inline-block;background:#6ee7a8;color:#0c1210;text-decoration:none;font-family:ui-sans-serif,system-ui,sans-serif;font-size:14px;font-weight:600;padding:12px 18px;">Manage monitor</a>
    `),
  });
}

export async function sendDownAlert(opts: {
  to: string;
  url: string;
  token: string;
  error: string | null;
  statusCode: number | null;
}) {
  const manageUrl = `${appUrl()}/m/${opts.token}`;
  const host = displayHost(opts.url);
  const detail =
    opts.error ??
    (opts.statusCode ? `HTTP ${opts.statusCode}` : "No response");

  const text = `DOWN: ${opts.url}

${detail}

Manage: ${manageUrl}`;

  return sendEmail({
    to: opts.to,
    subject: `DOWN — ${host}`,
    text,
    html: shell(`
      <h1 style="font-size:28px;font-weight:400;line-height:1.25;margin:0 0 16px;color:#ffb4a2;">${host} is down</h1>
      <p style="font-family:ui-sans-serif,system-ui,sans-serif;font-size:16px;line-height:1.6;color:#c5d2c8;margin:0 0 8px;">We couldn’t reach <strong style="color:#e8efe9;">${opts.url}</strong>.</p>
      <p style="font-family:ui-sans-serif,system-ui,sans-serif;font-size:14px;line-height:1.6;color:#9aaba0;margin:0 0 24px;">${detail}</p>
      <a href="${manageUrl}" style="display:inline-block;background:#ffb4a2;color:#0c1210;text-decoration:none;font-family:ui-sans-serif,system-ui,sans-serif;font-size:14px;font-weight:600;padding:12px 18px;">View monitor</a>
    `),
  });
}

export async function sendRecoveredAlert(opts: {
  to: string;
  url: string;
  token: string;
  statusCode: number | null;
}) {
  const manageUrl = `${appUrl()}/m/${opts.token}`;
  const host = displayHost(opts.url);

  const text = `RECOVERED: ${opts.url}

It’s responding again${opts.statusCode ? ` (HTTP ${opts.statusCode})` : ""}.

Manage: ${manageUrl}`;

  return sendEmail({
    to: opts.to,
    subject: `Back up — ${host}`,
    text,
    html: shell(`
      <h1 style="font-size:28px;font-weight:400;line-height:1.25;margin:0 0 16px;color:#6ee7a8;">${host} is back</h1>
      <p style="font-family:ui-sans-serif,system-ui,sans-serif;font-size:16px;line-height:1.6;color:#c5d2c8;margin:0 0 24px;">It’s responding again${opts.statusCode ? ` (HTTP ${opts.statusCode})` : ""}. We’ll keep watching.</p>
      <a href="${manageUrl}" style="display:inline-block;background:#6ee7a8;color:#0c1210;text-decoration:none;font-family:ui-sans-serif,system-ui,sans-serif;font-size:14px;font-weight:600;padding:12px 18px;">View monitor</a>
    `),
  });
}
