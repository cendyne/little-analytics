CREATE TABLE schema_migrations (version text primary key)
CREATE TABLE events (
  `id` integer primary key autoincrement,
  `date` real not null,
  `ip` text,
  `method` text,
  `user_agent` text,
  `path` text,
  `cookies` text,
  `body` text,
  `body_content_type` text,
  `headers` text
)
CREATE TABLE sqlite_sequence(name,seq)
CREATE INDEX events_date on events(date)
