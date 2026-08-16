# Local Supabase

Murmur’s backend is developed **locally first**. Do not link or push to a hosted project until Session 97.

## Prerequisites

1. **Docker Desktop** (or another Docker engine) must be installed **and running**. `supabase start` pulls and runs containers; it will fail if Docker is not up.
2. **Supabase CLI** 2.x. Install with Homebrew (`brew install supabase/tap/supabase`) or run via `npx supabase` from this repo.

This machine did **not** have Docker available when Session 5 ran, so `supabase start` was not verified here. After Docker is running, use the commands below.

## Commands

From the repo root (`/Users/zaree/Desktop/Murmur`):

```bash
supabase start
```

Wait until health checks pass. Then:

```bash
supabase status
```

Typical local ports (from `supabase/config.toml`):

| Service | Port |
| --- | --- |
| API (PostgREST + Auth gateway) | 54321 |
| Postgres | 54322 |
| Studio | 54323 |

Stop:

```bash
supabase stop
```

Reset the local DB (later sessions, after migrations exist):

```bash
supabase db reset
```

## Keys

`supabase start` prints `anon` / publishable and `service_role` keys for **this machine only**.

- Put the **anon / publishable** key in gitignored `Config/Supabase.local.xcconfig` (included from Debug). After `supabase start`, copy `API_URL` and `ANON_KEY` from `supabase status -o env`. Use `http:/$()/127.0.0.1:54321` so `//` is not treated as an xcconfig comment.
- **Never** put `service_role` in the app, widgets, or git ([SECURITY.md](SECURITY.md)).
- Release xcconfig stays empty until Session 97 (fail closed — the app still launches).
- Physical device (Session 18): `127.0.0.1` is the phone. Set `SUPABASE_URL` in `Config/Supabase.local.xcconfig` to `http:/$()/<your-mac-lan-ip>:54321`. Debug allows RFC1918 HTTP; Release does not.

`supabase/.env` is gitignored.

## Sessions 6–7 verification (profile + settings trigger)

After Docker is running and `supabase start` (or `supabase db reset`) has applied migrations, create a user through Auth (this is what fires the trigger in production):

```bash
# Anon key: `supabase status -o env` → ANON_KEY
curl -sS http://127.0.0.1:54321/auth/v1/signup \
  -H "apikey: $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email":"s06-verify@localhost","password":"password123"}'
```

Then in Studio (http://127.0.0.1:54323) or `psql` on port 54322:

```sql
select id, created_at from public.profiles;
```

Expect a `profiles` row whose `id` matches `auth.users.id` for that email, and a `user_settings` row:

```sql
select p.id, s.always_confirm
from public.profiles p
join public.user_settings s on s.user_id = p.id;
```

`always_confirm` should be `true`. Session 8 policies are in `supabase/migrations/20260815231518_rls_profiles_and_user_settings.sql`. Session 9 proves A cannot read B.

Do not use `user_metadata` for authorization. Do not put `service_role` in the iOS app.

## What init and Sessions 6–7 did

- Created `supabase/config.toml` (`project_id = "Murmur"`).
- Turned **Realtime** and **Storage** off to match the product (account + settings only).
- Session 6–7 added `public.profiles`, `public.user_settings`, and `private.handle_new_user`.

## If start fails

- Confirm Docker is running (`docker info`).
- First start needs network to pull images; allow several minutes.
- If a port in the 54320–54329 range is taken, stop the other process or change the port in `config.toml`.
