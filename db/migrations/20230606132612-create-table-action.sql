-- up
create table action (
  id integer primary key,
  name text not null,
  user_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  foreign key(user_id) references user(id)
)

-- down
drop table action
