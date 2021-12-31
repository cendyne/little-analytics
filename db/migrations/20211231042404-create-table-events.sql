-- up
create table events (
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

-- down
drop table events