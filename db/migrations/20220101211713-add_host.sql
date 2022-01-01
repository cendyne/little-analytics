-- up
alter table events add column `host` text

-- down
alter table events drop column `host`