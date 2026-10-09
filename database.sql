-- SPY MOVIE REQUEST database setup
-- Run this file in Supabase SQL Editor.
-- Create your first user via the website before assigning the admin role.

create schema if not exists private;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  role text not null default 'member' check (role in ('member','admin')),
  created_at timestamptz not null default now()
);
create table public.requests (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  movie_name text not null check (char_length(movie_name) between 1 and 150),
  release_year text not null default '',
  language text not null default '',
  details text not null default '',
  status text not null default 'Pending'
    check (status in ('Pending','Searching','Available','Unavailable','Replied')),
  created_at timestamptz not null default now()
);
create table public.messages (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.requests(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index requests_owner_idx on public.requests(owner_id, created_at desc);
create index messages_request_idx on public.messages(request_id, created_at);

create or replace function private.is_spy_admin()
returns boolean language sql stable security definer set search_path = ''
as $$
 select exists(select 1 from public.profiles p
 where p.id=(select auth.uid()) and p.role='admin');
$$;
revoke all on function private.is_spy_admin() from public, anon;
grant usage on schema private to authenticated;
grant execute on function private.is_spy_admin() to authenticated;

create or replace function private.create_spy_profile()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
 insert into public.profiles(id,display_name)
 values(new.id,coalesce(new.raw_user_meta_data->>'display_name',''));
 return new;
end;
$$;
drop trigger if exists spy_profile_after_signup on auth.users;
create trigger spy_profile_after_signup after insert on auth.users
for each row execute function private.create_spy_profile();

alter table public.profiles enable row level security;
alter table public.requests enable row level security;
alter table public.messages enable row level security;

revoke all on public.profiles from anon, authenticated;
revoke all on public.requests from anon, authenticated;
revoke all on public.messages from anon, authenticated;
grant select on public.profiles to authenticated;
grant update(display_name) on public.profiles to authenticated;
grant select,insert on public.requests to authenticated;
grant update(status) on public.requests to authenticated;
grant select,insert on public.messages to authenticated;

create policy "spy profile read own or admin" on public.profiles
for select to authenticated
using(id=(select auth.uid()) or (select private.is_spy_admin()));
create policy "spy profile update own" on public.profiles
for update to authenticated
using(id=(select auth.uid())) with check(id=(select auth.uid()));

create policy "spy request read owner or admin" on public.requests
for select to authenticated
using(owner_id=(select auth.uid()) or (select private.is_spy_admin()));
create policy "spy request create own" on public.requests
for insert to authenticated
with check(owner_id=(select auth.uid()));
create policy "spy admin update status" on public.requests
for update to authenticated
using((select private.is_spy_admin()))
with check((select private.is_spy_admin()));

create policy "spy message read owner or admin" on public.messages
for select to authenticated
using((select private.is_spy_admin()) or exists(
 select 1 from public.requests r where r.id=request_id and r.owner_id=(select auth.uid())
));
create policy "spy message create authorized" on public.messages
for insert to authenticated
with check(author_id=(select auth.uid()) and (
 (select private.is_spy_admin()) or exists(
   select 1 from public.requests r where r.id=request_id and r.owner_id=(select auth.uid())
 )
));

-- After creating your admin account on the website, run this separately:
-- update public.profiles set role='admin'
-- where id=(select id from auth.users where lower(email)=lower('YOUR-ADMIN-EMAIL@gmail.com'));
