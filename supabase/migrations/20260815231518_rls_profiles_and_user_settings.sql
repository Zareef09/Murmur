-- S08: FORCE RLS + per-command policies. No DELETE. No anon access.
-- Policies use (select auth.uid()), never user_metadata.
-- Trigger inserts still work because private.handle_new_user is security definer
-- owned by postgres (superuser bypasses FORCE RLS).

alter table public.profiles enable row level security;
alter table public.profiles force row level security;
alter table public.user_settings enable row level security;
alter table public.user_settings force row level security;

revoke all on table public.profiles from public, anon, authenticated;
revoke all on table public.user_settings from public, anon, authenticated;

grant select, update on table public.profiles to authenticated;
grant select, insert, update on table public.user_settings to authenticated;

create policy profiles_select_own
  on public.profiles
  for select
  to authenticated
  using ((select auth.uid()) = id);

create policy profiles_update_own
  on public.profiles
  for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy user_settings_select_own
  on public.user_settings
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy user_settings_insert_own
  on public.user_settings
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy user_settings_update_own
  on public.user_settings
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
