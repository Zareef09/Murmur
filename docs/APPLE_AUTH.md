# Sign in with Apple (Session 11)

Murmur signs in **natively** (AuthenticationServices → Supabase `signInWithIdToken`). Do **not** use a Safari / `signInWithOAuth` sheet in the iOS app ([SECURITY.md](SECURITY.md) §4). App code is Session 18; Xcode capability is Session 13. This file is **dashboard and Apple Developer setup only**.

Canonical docs: [Login with Apple](https://supabase.com/docs/guides/auth/social-login/auth-apple).

**Planned bundle ID:** `app.murmur.capture` (change this everywhere if you pick another id in Session 12).

---

## What you must do (native iOS — required)

### A. Apple Developer

1. Paid [Apple Developer](https://developer.apple.com) account.
2. **Identifiers → App IDs** → register an App ID.
   - Bundle ID: `app.murmur.capture` (explicit, not wildcard).
   - Description: Murmur.
   - Capabilities: enable **Sign in with Apple**.
   - **Server-to-Server Notification Endpoint:** leave **blank**. Supabase Auth does not support it.
3. Note your **Team ID** (10 characters, top right of the developer site). You will need it only if you later add web OAuth.
4. **Keys / .p8:** not required for native-only. Skip unless you do the optional web section below. Never put a `.p8` in git (already gitignored).

### B. Xcode (when the app exists — Session 13)

- Same bundle ID as the App ID.
- Signing team = that Apple Developer team.
- Capability: **Sign in with Apple**.

### C. Hosted Supabase (Session 97 project)

1. Open [Auth → Providers → Apple](https://supabase.com/dashboard/project/_/auth/providers).
2. Enable the Apple provider.
3. **Client IDs:** add the **App ID / bundle ID** `app.murmur.capture`.
   - Native `signInWithIdToken` accepts **any** client ID in this list as the token audience.
   - If you later add web OAuth, the **Services ID must be first** in the list (native IDs can follow). Native-only: one ID is enough.
4. **Secret Key / Services ID / Team ID** on this screen: leave empty for native-only. You do **not** rotate a secret every 6 months unless you enable web OAuth.
5. Save.

### D. Local Supabase (`supabase start`)

In `supabase/config.toml` under `[auth.external.apple]`:

- `enabled = true`
- `client_id = "app.murmur.capture"` (comma-separate extra App IDs if you add a test bundle later)
- Leave `secret` as `env(SUPABASE_AUTH_EXTERNAL_APPLE_SECRET)` and **do not set** that env var for native-only (no OAuth secret).
- `redirect_uri` can stay empty for native-only.

Then `npx supabase stop` && `npx supabase start` so Auth picks up the provider.

Local Auth still **validates the Apple identity token** with Apple’s servers. Simulator often cannot complete SIWA; **use a real device** (Session 18).

On a physical device, `127.0.0.1` is the phone, not your Mac. Put your Mac’s LAN IP in gitignored `Config/Supabase.local.xcconfig` (Debug allows private-range HTTP). Example: `SUPABASE_URL = http:/$()/192.168.1.10:54321`. Simulator can keep `127.0.0.1`.

---

## Optional: web OAuth (not used by the iOS app)

Only if you add a website that calls `signInWithOAuth({ provider: 'apple' })`. Native-only Murmur can skip this entire section.

1. **Identifiers → Services IDs** → e.g. `app.murmur.capture.web`, attached to the App ID.
2. Configure Website URLs on that Services ID:
   - **Domains and subdomains:** `<project-ref>.supabase.co`
   - **Return URL:** `https://<project-ref>.supabase.co/auth/v1/callback`
3. **Keys** → create a Sign in with Apple key, download `AuthKey_XXXXXXXXXX.p8` **once**. Store outside the repo. If lost, revoke and create a new key.
4. In the Supabase Apple provider:
   - Put the **Services ID first** in Client IDs, then the iOS App ID.
   - Team ID, Key ID, and generated secret (from the `.p8`).
5. Apple requires **generating a new client secret every 6 months** when OAuth is configured. Calendar reminder. Native-only setups do **not** have this duty.

Do not commit the `.p8`, the generated secret, or `service_role`.

---

## Nonce (implemented in Session 18 — do not skip)

1. Random nonce (e.g. 32 bytes).
2. `ASAuthorizationAppleIDRequest.nonce` = **SHA256(raw nonce)** as lowercase hex.
3. `signInWithIdToken` gets the **identity token string** and the **raw nonce** (pre-hash).
4. One nonce per attempt. Never log token, nonce, or authorization code.

---

## Product rules (do not “fix” later)

- Authorize with `auth.uid()` only. Do not put Apple email/name in RLS or in `public.profiles`.
- Hide My Email is fine.
- Apple’s full name is only on **first** native consent. Murmur v1 does not store names; do not `updateUser` metadata for authorization.
- Session lives in the **app Keychain**, not the widget App Group.

---

## Done when

- [ ] App ID `app.murmur.capture` exists with Sign in with Apple, empty notification URL.
- [ ] Hosted Apple provider enabled with that bundle ID in Client IDs (after you have a Murmur project).
- [x] Local `[auth.external.apple]` enabled with the same `client_id` when you use `supabase start` for iOS auth.
- [ ] No `.p8` in the repo.

iOS `signInWithIdToken` wiring is **Session 18**. Creating the Xcode project is **Session 12**.
