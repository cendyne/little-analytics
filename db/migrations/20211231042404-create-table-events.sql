-- up
create table events (
  id integer primary key,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table events