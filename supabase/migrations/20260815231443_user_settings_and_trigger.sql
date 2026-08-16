-- S07: user_settings + extend handle_new_user.
-- Client GRANTs and RLS policies are Session 8.

create table public.user_settings (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  always_confirm boolean not null default true,
  updated_at timestamptz not null default now()
);

comment on table public.user_settings is
  'Per-user preferences synced via Supabase. History is not stored here.';

alter table public.user_settings enable row level security;

revoke all on table public.user_settings from public, anon, authenticated;

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id)
  values (new.id);

  insert into public.user_settings (user_id, always_confirm)
  values (new.id, true);

  return new;
end;
$$;

revoke all on function private.handle_new_user() from public, anon, authenticated;
grant execute on function private.handle_new_user() to supabase_auth_admin;
