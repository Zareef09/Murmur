#!/usr/bin/env bash
# Run the Session 9 RLS proof against local Postgres.
# `supabase db query` cannot run this file (one statement only).
set -euo pipefail
cd "$(dirname "$0")/../.."
docker exec -i supabase_db_Murmur psql -U postgres -d postgres -v ON_ERROR_STOP=1 < supabase/tests/rls_proof.sql
