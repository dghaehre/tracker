CREATE TABLE schema_migrations (version text primary key)
CREATE TABLE user (
  id integer primary key,
  username text unique not null,
  password text not null,
  created_at integer not null default(strftime('%s', 'now'))
)
CREATE TABLE competition (
  id integer primary key,
  name text not null,
  user_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  foreign key(user_id) references user(id)
)
CREATE TABLE action (
  id integer primary key,
  name text not null,
  status text not null default('ACTIVE'), -- ACTIVE, DELETED
  user_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  foreign key(user_id) references user(id),
  UNIQUE (name, user_id)
)
CREATE TABLE record (
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