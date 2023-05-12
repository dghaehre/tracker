CREATE TABLE schema_migrations (version text primary key)
CREATE TABLE user (
  id integer primary key,
  username text unique not null,
  password text not null,
  created_at integer not null default(strftime('%s', 'now'))
)