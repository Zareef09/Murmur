-- S09 RLS proof. Run against local Postgres after migrations:
--   npx supabase db query --local -f supabase/tests/rls_proof.sql
-- Rolls back. Raises if any case fails.

begin;

create temporary table rls_proof (
  case_id text primary key,
  passed boolean not null,
  detail text not null
);

grant all on table rls_proof to public, anon, authenticated;

do $proof$
declare
  user_a constant uuid := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  user_b constant uuid := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  n int;
  own_flag boolean;
  b_flag boolean;
begin
  delete from auth.users where id in (user_a, user_b);

  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, confirmation_token, email_change,
    email_change_token_new, recovery_token
  ) values
    (
      '00000000-0000-0000-0000-000000000000', user_a,
      'authenticated', 'authenticated', 'rls-a@murmur.test',
      crypt('unused', gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
      now(), now(), '', '', '', ''
    ),
    (
      '00000000-0000-0000-0000-000000000000', user_b,
      'authenticated', 'authenticated', 'rls-b@murmur.test',
      crypt('unused', gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
      now(), now(), '', '', '', ''
    );

  if (select count(*) from public.profiles where id in (user_a, user_b)) <> 2 then
    raise exception 'trigger did not create both profiles';
  end if;
  if (select count(*) from public.user_settings where user_id in (user_a, user_b)) <> 2 then
    raise exception 'trigger did not create both user_settings';
  end if;

  -- 1. anon
  begin
    execute 'set local role anon';
    begin
      execute 'select count(*) from public.profiles' into n;
      execute 'select count(*) from public.user_settings' into n;
      if n = 0 then
        insert into rls_proof values ('1_anon', true, 'anon select returned 0 rows');
      else
        insert into rls_proof values ('1_anon', false, format('anon saw %s settings rows', n));
      end if;
    exception
      when insufficient_privilege then
        insert into rls_proof values ('1_anon', true, 'anon permission denied (expected)');
    end;
    execute 'reset role';
  end;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', user_a::text, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  -- 2. A selects settings → only A
  select count(*) into n from public.user_settings;
  if n = 1 then
    insert into rls_proof values ('2_a_select_own', true, 'A sees 1 settings row');
  else
    insert into rls_proof values ('2_a_select_own', false, format('A saw %s rows', n));
  end if;

  -- 3. A selects B explicitly → 0
  select count(*) into n from public.user_settings where user_id = user_b;
  if n = 0 then
    insert into rls_proof values ('3_a_select_b', true, 'A cannot see B settings');
  else
    insert into rls_proof values ('3_a_select_b', false, 'A saw B settings');
  end if;

  -- 4. A updates B → 0 rows, B unchanged
  update public.user_settings set always_confirm = false where user_id = user_b;
  get diagnostics n = row_count;
  execute 'reset role';
  select always_confirm into b_flag from public.user_settings where user_id = user_b;
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', user_a::text, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';
  if n = 0 and b_flag = true then
    insert into rls_proof values ('4_a_update_b', true, 'B always_confirm still true');
  else
    insert into rls_proof values (
      '4_a_update_b', false,
      format('row_count=%s b_flag=%s', n, b_flag)
    );
  end if;

  -- 5. A inserts settings for B → rejected
  begin
    insert into public.user_settings (user_id, always_confirm) values (user_b, false);
    insert into rls_proof values ('5_a_insert_b', false, 'insert for B succeeded');
  exception
    when others then
      insert into rls_proof values ('5_a_insert_b', true, sqlerrm);
  end;

  -- 6. A updates own → succeeds
  update public.user_settings set always_confirm = false where user_id = user_a;
  get diagnostics n = row_count;
  select always_confirm into own_flag from public.user_settings where user_id = user_a;
  if n = 1 and own_flag = false then
    insert into rls_proof values ('6_a_update_own', true, 'A updated own always_confirm');
  else
    insert into rls_proof values (
      '6_a_update_own', false,
      format('row_count=%s own_flag=%s', n, own_flag)
    );
  end if;

  -- 7. A cannot delete own profile
  begin
    delete from public.profiles where id = user_a;
    insert into rls_proof values ('7_a_delete_own', false, 'delete succeeded');
  exception
    when insufficient_privilege then
      insert into rls_proof values ('7_a_delete_own', true, 'delete permission denied');
    when others then
      insert into rls_proof values ('7_a_delete_own', true, sqlerrm);
  end;

  execute 'reset role';
end;
$proof$;

select case_id, passed, detail from rls_proof order by case_id;

do $fail$
begin
  if exists (select 1 from rls_proof where passed is not true) then
    raise exception 'RLS proof failed: %',
      (select string_agg(case_id, ', ') from rls_proof where passed is not true);
  end if;
end;
$fail$;

rollback;
