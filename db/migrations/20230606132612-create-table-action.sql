-- up
create table action (
  id integer primary key,
  name text not null,
  status text not null default('ACTIVE'), -- ACTIVE, DELETED
  user_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  foreign key(user_id) references user(id),
  UNIQUE (name, user_id)
)

-- down
drop table action
