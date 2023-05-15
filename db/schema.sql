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