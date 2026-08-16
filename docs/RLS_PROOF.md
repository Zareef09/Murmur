# RLS proof (Session 9)

Policy source: [SECURITY.md](SECURITY.md) §3.8. SQL: [`supabase/tests/rls_proof.sql`](../supabase/tests/rls_proof.sql).

## How to run

`npx supabase db query` only accepts **one** SQL statement, so it cannot run this file. Use `psql` in the local DB container instead.

Docker must be running, and you should already have done `npx supabase start` (and `npx supabase db reset` after pulling new migrations). From the repo root:

```bash
docker exec -i supabase_db_Murmur psql -U postgres -d postgres -v ON_ERROR_STOP=1 < supabase/tests/rls_proof.sql
```

Or: `bash supabase/tests/run_rls_proof.sh`

The script impersonates `anon` and user A, checks all seven cases, then **rolls back**. It raises if any case fails.

## Cases

| ID | Expectation |
| --- | --- |
| `1_anon` | Anon `select` on `profiles` / `user_settings` is 0 rows or permission denied |
| `2_a_select_own` | Authenticated A sees exactly one `user_settings` row |
| `3_a_select_b` | A selecting B’s `user_id` returns 0 rows |
| `4_a_update_b` | A update of B affects 0 rows; B’s `always_confirm` stays true |
| `5_a_insert_b` | A insert with `user_id = B` is rejected |
| `6_a_update_own` | A can update own `always_confirm` |
| `7_a_delete_own` | A cannot `delete` own `profiles` row (no GRANT / no policy) |

Authorization uses `auth.uid()` via `request.jwt.claims`. Not `user_metadata`.

## Live result

**Pass — 15 Aug 2026** (local `supabase_db_Murmur`, after `db reset`). All seven `passed = t`.

| case_id | passed | detail |
| --- | --- | --- |
| 1_anon | t | anon permission denied (expected) |
| 2_a_select_own | t | A sees 1 settings row |
| 3_a_select_b | t | A cannot see B settings |
| 4_a_update_b | t | B always_confirm still true |
| 5_a_insert_b | t | new row violates row-level security policy for table "user_settings" |
| 6_a_update_own | t | A updated own always_confirm |
| 7_a_delete_own | t | delete permission denied |
