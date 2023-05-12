-- up
create table user (
  id integer primary key,
  username text unique not null,
  password text not null,
  created_at integer not null default(strftime('%s', 'now'))
)

-- down
drop table user
