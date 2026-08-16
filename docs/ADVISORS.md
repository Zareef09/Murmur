# Database advisors (Session 10)

Run after Docker is up and migrations are applied ([LOCAL_SUPABASE.md](LOCAL_SUPABASE.md)):

```bash
npx supabase db reset
npx supabase db advisors --local --type security --fail-on error
```

`--fail-on error` exits non-zero if any **ERROR** (critical) security advisor remains. WARN/INFO (e.g. unused index, initplan) can be cleaned later; they are not this session’s bar.

Hosted advisors wait until Session 97 (no Murmur project yet). Do not run advisors against unrelated org projects.

## Live result (this session)

**Pass — 15 Aug 2026.** `npx supabase db advisors --local --type security --fail-on error` → `No issues found`.

## Static review vs ERROR-level checks

Source: [Performance and Security Advisors](https://supabase.com/docs/guides/database/database-advisors). Our migrations were checked against the ERROR/security items we can control without a running DB:

| Check | Our schema |
| --- | --- |
| `0002_auth_users_exposed` | No views over `auth.users` |
| `0007_policy_exists_rls_disabled` | RLS enabled before policies |
| `0008_rls_enabled_no_policy` | SELECT/UPDATE (and settings INSERT) policies exist |
| `0010_security_definer_view` | No views |
| `0011_function_search_path_mutable` | `private.handle_new_user` has `set search_path = ''` |
| `0013_rls_disabled_in_public` | RLS + FORCE on `profiles` and `user_settings` |
| `0015_rls_references_user_metadata` | Policies use `(select auth.uid())` only |
| `0012_auth_allow_anonymous_sign_ins` | `enable_anonymous_sign_ins = false` in `config.toml` |

Expected: **no ERROR security advisors** from our SQL. Confirm by running the command above and paste output here.

Performance (`0003_auth_rls_initplan`) should already be satisfied by the `(select auth.uid())` wrapper; treat leftover WARN as non-blocking for S10.
