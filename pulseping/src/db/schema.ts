import { integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const monitors = sqliteTable("monitors", {
  id: text("id").primaryKey(),
  url: text("url").notNull(),
  email: text("email").notNull(),
  token: text("token").notNull().unique(),
  status: text("status", { enum: ["up", "down", "unknown"] })
    .notNull()
    .default("unknown"),
  lastCheckedAt: integer("last_checked_at"),
  lastStatusCode: integer("last_status_code"),
  lastError: text("last_error"),
  consecutiveFailures: integer("consecutive_failures").notNull().default(0),
  createdAt: integer("created_at").notNull(),
});

export type Monitor = typeof monitors.$inferSelect;
export type NewMonitor = typeof monitors.$inferInsert;
