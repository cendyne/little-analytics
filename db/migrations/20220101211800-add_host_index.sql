-- up
create index events_host on events(`host`)

-- down
drop index events_host