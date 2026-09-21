# PulsePing

Know when a website goes down — add a URL + email, get alerted.

## What it does

1. You submit a website URL and an email on the homepage
2. PulsePing checks the site immediately and gives you a private manage link
3. A cron job re-checks every 5 minutes
4. If a site fails twice in a row, you get a **DOWN** email; when it recovers, a **Back up** email

## Stack

- Next.js (App Router) + TypeScript
- Turso / libSQL (SQLite locally via `file:local.db`)
- Resend for email
- Vercel Cron (or any external cron hitting `/api/cron/check`)

## Local setup

```bash
cd pulseping
cp .env.example .env.local
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

Without `RESEND_API_KEY`, alert emails are printed in the terminal.

### Realtime monitor loop (recommended)

The website shows status. The Python worker keeps it accurate with the classic forever loop:

1. Wake up  
2. `requests.get(url)` for each monitor  
3. 200–399 → up; timeout / error / bad status → down  
4. If down (state change) → email alert  
5. `time.sleep(CHECK_INTERVAL)`  
6. Repeat forever  

```bash
# terminal 1
npm run dev

# terminal 2
npm run monitor:install
npm run monitor:run
```

Default interval is **60 seconds** (`CHECK_INTERVAL` in `.env.local`). The manage page also live-probes every 30s while open.

### Manual one-shot check

```bash
curl -H "Authorization: Bearer dev-cron-secret-change-me" \
  http://localhost:3000/api/cron/check
```

## Deploy today (Vercel)

### 1. Create a free Turso database

Local SQLite files do not persist on Vercel.

1. Install CLI: `brew install tursodatabase/tap/turso` (or see [turso.tech](https://turso.tech))
2. `turso auth signup` / `turso auth login`
3. `turso db create pulseping`
4. `turso db show pulseping --url` → `DATABASE_URL`
5. `turso db tokens create pulseping` → `DATABASE_AUTH_TOKEN`

### 2. Create a Resend API key

1. Sign up at [resend.com](https://resend.com)
2. Create an API key → `RESEND_API_KEY`
3. Until you verify a domain, use `EMAIL_FROM="PulsePing <onboarding@resend.dev>"` and send only to your own Resend account email

### 3. Push to GitHub and deploy on Vercel

```bash
git add .
git commit -m "Ship PulsePing uptime monitor"
git remote add origin <your-repo-url>
git push -u origin main
```

Import the repo in Vercel, then set env vars:

| Variable | Example |
|---|---|
| `DATABASE_URL` | `libsql://pulseping-….turso.io` |
| `DATABASE_AUTH_TOKEN` | Turso token |
| `RESEND_API_KEY` | `re_…` |
| `EMAIL_FROM` | `PulsePing <onboarding@resend.dev>` |
| `NEXT_PUBLIC_APP_URL` | `https://your-app.vercel.app` |
| `CRON_SECRET` | long random string |

### 4. Cron schedule notes

`vercel.json` schedules `/api/cron/check` every 5 minutes. On the **Hobby** plan, Vercel only runs crons once per day — for real 5-minute checks either:

- Upgrade to Pro, or
- Use a free external ping (e.g. [cron-job.org](https://cron-job.org)) every 5 minutes:

```http
GET https://your-app.vercel.app/api/cron/check
Authorization: Bearer <CRON_SECRET>
```

Vercel Cron automatically sends `Authorization: Bearer $CRON_SECRET` when `CRON_SECRET` is set.

## Project map

```
src/app/page.tsx              Landing + watch form
src/app/m/[token]/page.tsx   Private manage page
src/app/api/monitors/         Create / check / delete
src/app/api/cron/check/       Scheduled uptime sweep
src/lib/check.ts              HTTP probe
src/lib/email.ts              Resend templates
src/lib/monitors.ts           Create + state transitions
src/db/                       libSQL schema + client
```
