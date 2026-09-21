import { createClient, type Client } from "@libsql/client";
import { drizzle, type LibSQLDatabase } from "drizzle-orm/libsql";
import * as schema from "./schema";

const SCHEMA_SQL = `
CREATE TABLE IF NOT EXISTS monitors (
  id TEXT PRIMARY KEY NOT NULL,
  url TEXT NOT NULL,
  email TEXT NOT NULL,
  token TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL DEFAULT 'unknown',
  last_checked_at INTEGER,
  last_status_code INTEGER,
  last_error TEXT,
  consecutive_failures INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS monitors_token_idx ON monitors (token);
CREATE INDEX IF NOT EXISTS monitors_email_idx ON monitors (email);
`;

type Db = LibSQLDatabase<typeof schema>;

declare global {
  // eslint-disable-next-line no-var
  var __pulsepingClient: Client | undefined;
  // eslint-disable-next-line no-var
  var __pulsepingDb: Db | undefined;
  // eslint-disable-next-line no-var
  var __pulsepingReady: Promise<void> | undefined;
}

function getDatabaseUrl() {
  return process.env.DATABASE_URL ?? "file:local.db";
}

function createDbClient() {
  const url = getDatabaseUrl();
  const authToken = process.env.DATABASE_AUTH_TOKEN;

  if (url.startsWith("file:") || !authToken) {
    return createClient({ url });
  }

  return createClient({ url, authToken });
}

async function ensureSchema(client: Client) {
  const statements = SCHEMA_SQL.split(";")
    .map((s) => s.trim())
    .filter(Boolean);

  for (const statement of statements) {
    await client.execute(statement);
  }
}

export async function getDb() {
  if (!globalThis.__pulsepingClient) {
    globalThis.__pulsepingClient = createDbClient();
  }

  if (!globalThis.__pulsepingDb) {
    globalThis.__pulsepingDb = drizzle(globalThis.__pulsepingClient, {
      schema,
    });
  }

  if (!globalThis.__pulsepingReady) {
    globalThis.__pulsepingReady = ensureSchema(globalThis.__pulsepingClient);
  }

  await globalThis.__pulsepingReady;
  return globalThis.__pulsepingDb;
}
