# SPY MOVIE REQUEST — ULTRA FUTURE

A GitHub Pages frontend with Supabase Auth + Postgres request/chat storage.

## Files
- `index.html` — website frontend
- `database.sql` — tables, trigger, and row-level security policies

## Setup
1. Create a project at https://supabase.com/dashboard
2. Open SQL Editor and run the entire `database.sql`.
3. In Authentication settings, enable Email/Password. Decide whether to require email confirmation.
4. In Project Settings / API, copy the Project URL and **publishable** key.
5. Edit `index.html`:
   - Replace `SUPABASE_URL`
   - Replace `SUPABASE_KEY` with the publishable key (never use a secret/service_role key)
   - Replace the WhatsApp and Telegram links in `LINKS`
6. Push `index.html` to the root of a GitHub repository.
7. GitHub repository → Settings → Pages → Deploy from a branch → `main` → `/ (root)`.
8. Visit the published URL and create your intended admin account.
9. In Supabase SQL Editor, run this with your real account email:
   `update public.profiles set role='admin' where id=(select id from auth.users where lower(email)=lower('YOUR-ADMIN-EMAIL@gmail.com'));`
10. Log out and log in again so the website reloads your role.

## Important limitations / launch checks
- This is a starter project, not a security-audited production app.
- Keep RLS enabled. Never put a Supabase secret/service_role key in frontend code.
- The UI refreshes messages manually; it does not yet use realtime subscriptions.
- Before public launch, test with two separate member accounts and one admin account:
  member A can only read A's requests/messages; member B cannot read A's chat; admin can see/reply to all.
- The profile update policy permits members to update their own display name only through column grants. Do not grant role updates to clients.
- Configure Auth email confirmation and redirect URLs for your GitHub Pages origin.
- If signup is blocked or requests fail, inspect Supabase Auth settings, SQL policy errors, and browser console.
