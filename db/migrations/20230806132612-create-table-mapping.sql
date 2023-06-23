-- up
create table mapping (
  id integer primary key,
  competition_id integer not null,
  action_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  foreign key(competition_id) references competition(id),
  foreign key(action_id) references action(id),
  UNIQUE (competition_id, action_id)
)

-- down
drop table mapping
