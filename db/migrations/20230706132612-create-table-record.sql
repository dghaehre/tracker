-- up
create table record (
  id integer primary key,
  amount int not null default 0,
  action_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  year_day integer not null,
  year integer not null,
  foreign key(action_id) references action(id),
  UNIQUE (action_id, year, year_day)
)

-- down
drop table record
