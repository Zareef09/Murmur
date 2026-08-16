-- S06: private schema, profiles, auth.users → profile trigger.
-- user_settings is Session 7 (this function will be replaced then).
-- RLS policies and GRANTs to authenticated are Session 8.

create schema if not exists private;

revoke all on schema private from public, anon, authenticated;

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is
  'Murmur account row. id = auth.users.id. No PII. RLS policies in a later migration.';

alter table public.profiles enable row level security;

revoke all on table public.profiles from public, anon, authenticated;

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$$;

revoke all on function private.handle_new_user() from public, anon, authenticated;
grant execute on function private.handle_new_user() to supabase_auth_admin;
grant usage on schema private to supabase_auth_admin;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function private.handle_new_user();
