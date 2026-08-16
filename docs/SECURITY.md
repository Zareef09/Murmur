# Murmur — Security

> Product: [CAPTURE_SPEC.md](CAPTURE_SPEC.md). Sessions: [CAPTURE_MASTER_PLAN.md](CAPTURE_MASTER_PLAN.md). Visual: [CAPTURE_DESIGN_BRIEF.md](CAPTURE_DESIGN_BRIEF.md).  
> This file is **policy**. Sessions 6–11 and 17–23 implement it; they must not invent a different access model.

**Threat we care about:** another person (or a leaked anon key plus a script) reading or changing someone else’s settings; speech or history leaving the device; EventKit identifiers or tokens leaking into logs, widgets, or the cloud.

**Threat we accept in v1:** a thief with an unlocked phone and the Murmur passcode/biometrics already satisfied can use the app as the owner. We do not add a second Murmur PIN.

---

## 1. Data inventory

| Asset | Where it lives | Leaves device? | TTL / deletion |
| --- | --- | --- | --- |
| Mic PCM / recognition buffers | RAM only | No | Dropped when listening ends |
| Live / final transcript | RAM (then `title` only if saved) | No | Not stored as raw transcript |
| `Capture` history row | SwiftData, app sandbox | No | Delete if `createdAt` &lt; now − 3 days; user swipe; Undo |
| EventKit item | Apple Reminders / Calendar | No (Apple’s apps) | User or Undo; **not** on history TTL |
| EventKit identifier | SwiftData field only | No | Dies with the history row |
| `always_confirm` last-known | Local cache (UserDefaults or SwiftData settings row) | Yes — mirrored to `user_settings` | Survives reinstall only after sign-in + fetch |
| `profiles` / `user_settings` | Supabase Postgres | Yes — those columns only | Cascade on `auth.users` delete |
| Auth session (access/refresh) | iOS Keychain, this app | Refresh hits Supabase Auth | Sign out; Keychain item is this app’s |
| Apple identity token | RAM during sign-in | Sent once to Supabase Auth | Not persisted by us |
| Publishable / anon key | App binary / xcconfig | Public by design | Never `service_role` |
| Widget App Group | Shared defaults: start-listening flag only | N/A | No tokens, history, titles |

**Never create:** Storage buckets for Murmur, Realtime channels for user content, Edge Functions that take transcripts, analytics SDKs, CloudKit, `captures` (or similar) tables in Postgres.

---

## 2. Trust boundaries

```
[Mic] --RAM--> [On-device Speech] --RAM--> [Parse] --local--> [EventKit]
                                              |
                                              +--local--> [SwiftData history]
[Apple SIWA] --id_token+nonce--> [Supabase Auth] --JWT--> [PostgREST]
[PostgREST] --RLS--> [profiles, user_settings] only
[Widget] --App Group flag--> [Main app]   // no JWT in the extension
```

The iOS app uses the **anon / publishable** key. Authorization is **RLS + JWT `sub`**, not “the app filtered the query.” A copied key must still see **zero rows** when unauthenticated, and **only the caller’s rows** when authenticated.

---

## 3. Postgres schema (canonical — implement in S06–S08)

### 3.1 Roles and defaults

After tables exist:

```sql
revoke all on table public.profiles from public, anon, authenticated;
revoke all on table public.user_settings from public, anon, authenticated;

grant select, update on table public.profiles to authenticated;
-- insert on profiles: trigger only, not the client
grant select, insert, update on table public.user_settings to authenticated;
-- no delete from client on either table (v1)
```

`anon` gets **nothing**. Do not grant `delete` on `profiles` to `authenticated` in v1.

### 3.2 `private` schema for definer code

```sql
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
-- postgres / supabase_admin keep access for migrations
```

Security-definer functions live in `private`. **Do not** put them in `public`. `search_path` must be set (empty or `private, public` as required) so they cannot be hijacked.

### 3.3 `public.profiles`

```sql
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index profiles_id_idx on public.profiles (id); -- PK already covers; keep if advisors ask
```

No email, name, or Apple user identifier columns. Auth already has the user record. Do not copy PII here unless a later spec session adds a column.

### 3.4 `public.user_settings`

```sql
create table public.user_settings (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  always_confirm boolean not null default true,
  updated_at timestamptz not null default now()
);
```

Add columns only with a new migration.

### 3.5 Trigger: new auth user → profile + settings

`private.handle_new_user()` `security definer`, attached to `auth.users` **after insert**. Inserts `profiles (id)` then `user_settings (user_id)` with `always_confirm = true`. Must not read `raw_user_meta_data` for authorization (there is none to apply).

### 3.6 RLS (S08)

Enable **and force** RLS so table owners in unusual roles still cannot skip it:

```sql
alter table public.profiles enable row level security;
alter table public.profiles force row level security;
alter table public.user_settings enable row level security;
alter table public.user_settings force row level security;
```

Use `(select auth.uid())` so the uid is evaluated once, not per row. **Never** `auth.jwt() -> user_metadata` / `raw_user_meta_data`. **Never** a single `for all` policy if it would grant delete; use per-command policies.

**profiles — SELECT**

```sql
create policy profiles_select_own
  on public.profiles
  for select
  to authenticated
  using ((select auth.uid()) = id);
```

**profiles — UPDATE** (needs SELECT as well, already above)

```sql
create policy profiles_update_own
  on public.profiles
  for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);
```

No INSERT/DELETE policies for `authenticated` on `profiles`. The trigger runs as definer.

**user_settings — SELECT / INSERT / UPDATE**

```sql
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
```

INSERT exists so a client can recover if the trigger failed; `with check` still ties the row to `auth.uid()`. Prefer the trigger as the normal path.

### 3.7 Views

Do not add `public` views in v1. If one is added later: `with (security_invoker = true)` and still RLS on base tables. Revoke `anon`.

### 3.8 RLS proof (S09) — required cases

Run as JWT user A and user B (or `set request.jwt.claim.sub`):

1. Anon: `select * from profiles` and `user_settings` → 0 rows (or permission denied).
2. A selects settings → only A’s row.
3. A selects B’s `user_id` explicitly → 0 rows.
4. A updates B’s `always_confirm` → 0 rows, B unchanged.
5. A inserts `user_settings` with `user_id = B` → rejected.
6. A updates own `always_confirm` → succeeds.
7. A cannot `delete` own profile via Data API.

Document pass/fail in the session hand-off.

---

## 4. Sign in with Apple (S18, checklist S11)

> Native setup checklist (Apple Developer + Supabase dashboard): [APPLE_AUTH.md](APPLE_AUTH.md). Native only. Do not use a Safari OAuth sheet for the iOS app.

**Nonce (replay protection) — required:**

1. Generate a cryptographically random nonce (e.g. 32 bytes, hex or base64url).
2. Set `ASAuthorizationAppleIDRequest.nonce` to **SHA256(nonce)** (hex lowercase), per Apple + [Supabase Login with Apple](https://supabase.com/docs/guides/auth/social-login/auth-apple).
3. Call `signInWithIdToken` with the **identity token** (string) and the **raw nonce** (the pre-hash value), provider Apple.
4. Do not log the nonce, identity token, or authorization code.
5. One nonce per attempt; never reuse.

Authorization: `auth.uid()` only. Ignore Apple email/name in `user_metadata` for any policy. Hide-my-email is fine; we do not store email in `profiles`.

Session: persist via supabase-swift’s session storage backed by **Keychain** (this app, not the App Group). Restore on launch. Sign out: `signOut` + delete Keychain session. Deleting a user in the dashboard does **not** instantly kill a stolen refresh token until expiry or revocation — v1 sign-out is the user control; account deletion UI is an Open Decision.

---

## 5. Key handling (S17)

| Key | In the iOS app? |
| --- | --- |
| Publishable / anon | Yes. xcconfig or Info.plist. Treat as public. |
| `service_role` / secret | **Never.** Not in the repo, not in xcconfig committed to git, not in TestFlight. |
| Database password | Never in the app. |

Fail **closed** if URL or anon key is missing (do not start a client with empty strings). ATS stays default HTTPS. Only the configured Supabase project host. No extra ATS exception domains.

`.gitignore` (S04) must ignore `.env`, `supabase/.env`, and any `*.local.xcconfig` that holds a hosted URL you do not want in git. Local `supabase start` keys are for the machine, not the App Store binary.

Hosted project wiring is Session 97.

---

## 6. iOS client rules (S17–S23, persistence later)

- Queries against `profiles` / `user_settings` always as the signed-in user; never a user-id parameter from UI without also matching the session (RLS is the backstop).
- Settings: cache last-known `always_confirm` locally. Capture must work offline **after** first successful sign-in. First sign-in requires network.
- Debounce settings upserts; `with check` must remain `auth.uid() = user_id`.
- Widget / App Intents extension: **no** supabase-swift, **no** JWT. Shared flag only: “start listening when the app next becomes active.”
- SwiftData: file protection complete or complete-until-first-unlock if background intents cannot wait (decide in S41; do not weaken without noting it here).
- Screenshots: capture and clarify views `privacySensitive()` where the API exists.
- Speech: `requiresOnDeviceRecognition = true`. If the locale cannot, show copy — **do not** set the flag false to get network recognition.

---

## 7. Logging ban

`os.Logger` (or the S43 wrapper) only. **Never** log:

- transcript, `taskText`, `title`
- EventKit identifiers
- access/refresh tokens, Apple identity token, nonce
- full JWT
- email / Apple user id

Allowed: state names (`listening`), permission enum, HTTP status **without** bodies, “settings upsert ok.”

No `print` of user content. DEBUG previews must use fake titles, not production logs.

---

## 8. EventKit least privilege

Create/update/delete **only** items whose identifier we stored. Never list all calendars/reminders into Murmur UI. Never upload identifiers.

---

## 9. App Store privacy nutrition (draft for S46 / S96)

Not “Data Not Collected.” We collect:

| Type | Linked to identity? | Used for tracking? | Purpose |
| --- | --- | --- | --- |
| User ID (Supabase `auth.uid()`, Apple’s opaque user via Auth) | Yes (account) | No | App functionality (sign-in, settings sync) |
| Product interaction (the `always_confirm` preference) | Yes | No | App functionality |

**Not collected:** precise location, audio recordings (not stored), contacts, browsing history, diagnostics SDKs, advertising data. History, transcripts, and EventKit content are **not** sent to Murmur’s servers.

Tracking: **no**. No third-party ads.

Sign in with Apple must be mentioned in the listing (S96).

---

## 10. What later sessions must not do

- Add a `captures` table “just in case.”
- Put `service_role` in the widget “to make intents work.”
- Use `for all` policies that include DELETE on profiles.
- Authorize with `user_metadata`.
- Fall back to cloud speech.
- Sync history to Supabase without a new spec + new RLS (that is a different product).

Account deletion (Auth user + cascade) is **not** built in v1 unless a later session is added; if App Store requires it before submit, stop and ask.
