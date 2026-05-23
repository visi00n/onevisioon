create extension if not exists pgcrypto;

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  avatar_url text,
  is_public boolean not null default false,
  selected_version text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_selected_version_check
    check (selected_version is null or selected_version in ('free', 'premium'))
);

create table if not exists public.user_sync_snapshots (
  user_id uuid primary key references auth.users (id) on delete cascade,
  schema_version integer not null default 1,
  snapshot jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.prayer_feed_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null,
  handle text not null,
  prayer_topic text not null,
  message text not null,
  amens integer not null default 0 check (amens >= 0),
  status text not null default 'published',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint prayer_feed_posts_status_check
    check (status in ('published', 'hidden'))
);

create table if not exists public.creation_feed_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null,
  handle text not null,
  kind text not null,
  caption text not null,
  scripture_reference text not null default '',
  hearts integer not null default 0 check (hearts >= 0),
  did_feature boolean not null default false,
  status text not null default 'published',
  attachment_file_names text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint creation_feed_posts_status_check
    check (status in ('published', 'hidden'))
);

create table if not exists public.creation_feed_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.creation_feed_posts (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null,
  handle text not null,
  body text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  full_name text,
  source text not null default 'app',
  created_at timestamptz not null default now()
);

create index if not exists idx_prayer_feed_posts_user_id
  on public.prayer_feed_posts using btree (user_id);

create index if not exists idx_prayer_feed_posts_created_at
  on public.prayer_feed_posts using btree (created_at desc);

create index if not exists idx_creation_feed_posts_user_id
  on public.creation_feed_posts using btree (user_id);

create index if not exists idx_creation_feed_posts_created_at
  on public.creation_feed_posts using btree (created_at desc);

create index if not exists idx_creation_feed_comments_post_id
  on public.creation_feed_comments using btree (post_id);

create index if not exists idx_creation_feed_comments_user_id
  on public.creation_feed_comments using btree (user_id);

create index if not exists idx_user_sync_snapshots_updated_at
  on public.user_sync_snapshots using btree (updated_at desc);

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row
execute procedure public.handle_updated_at();

drop trigger if exists trg_user_sync_snapshots_updated_at on public.user_sync_snapshots;
create trigger trg_user_sync_snapshots_updated_at
before update on public.user_sync_snapshots
for each row
execute procedure public.handle_updated_at();

drop trigger if exists trg_prayer_feed_posts_updated_at on public.prayer_feed_posts;
create trigger trg_prayer_feed_posts_updated_at
before update on public.prayer_feed_posts
for each row
execute procedure public.handle_updated_at();

drop trigger if exists trg_creation_feed_posts_updated_at on public.creation_feed_posts;
create trigger trg_creation_feed_posts_updated_at
before update on public.creation_feed_posts
for each row
execute procedure public.handle_updated_at();

drop trigger if exists trg_creation_feed_comments_updated_at on public.creation_feed_comments;
create trigger trg_creation_feed_comments_updated_at
before update on public.creation_feed_comments
for each row
execute procedure public.handle_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(
      new.raw_user_meta_data ->> 'full_name',
      new.raw_user_meta_data ->> 'name',
      new.raw_user_meta_data ->> 'display_name'
    ),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do update
  set
    email = excluded.email,
    display_name = coalesce(excluded.display_name, public.profiles.display_name),
    avatar_url = coalesce(excluded.avatar_url, public.profiles.avatar_url),
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();

grant usage on schema public to anon, authenticated, service_role;

grant select on public.profiles to authenticated;
grant insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.profiles to service_role;

grant select, insert, update, delete on public.user_sync_snapshots to authenticated;
grant select, insert, update, delete on public.user_sync_snapshots to service_role;

grant select on public.prayer_feed_posts to authenticated;
grant insert, update, delete on public.prayer_feed_posts to authenticated;
grant select, insert, update, delete on public.prayer_feed_posts to service_role;

grant select on public.creation_feed_posts to authenticated;
grant insert, update, delete on public.creation_feed_posts to authenticated;
grant select, insert, update, delete on public.creation_feed_posts to service_role;

grant select on public.creation_feed_comments to authenticated;
grant insert, update, delete on public.creation_feed_comments to authenticated;
grant select, insert, update, delete on public.creation_feed_comments to service_role;

grant select, insert, update, delete on public.newsletter_subscribers to service_role;

alter table public.profiles enable row level security;
alter table public.user_sync_snapshots enable row level security;
alter table public.prayer_feed_posts enable row level security;
alter table public.creation_feed_posts enable row level security;
alter table public.creation_feed_comments enable row level security;
alter table public.newsletter_subscribers enable row level security;

drop policy if exists "profiles_select_self_or_public" on public.profiles;
create policy "profiles_select_self_or_public"
on public.profiles
for select
to authenticated
using (
  is_public = true
  or (select auth.uid()) = id
);

drop policy if exists "profiles_insert_self" on public.profiles;
create policy "profiles_insert_self"
on public.profiles
for insert
to authenticated
with check ((select auth.uid()) = id);

drop policy if exists "profiles_update_self" on public.profiles;
create policy "profiles_update_self"
on public.profiles
for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

drop policy if exists "user_sync_snapshots_select_own" on public.user_sync_snapshots;
create policy "user_sync_snapshots_select_own"
on public.user_sync_snapshots
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "user_sync_snapshots_insert_own" on public.user_sync_snapshots;
create policy "user_sync_snapshots_insert_own"
on public.user_sync_snapshots
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "user_sync_snapshots_update_own" on public.user_sync_snapshots;
create policy "user_sync_snapshots_update_own"
on public.user_sync_snapshots
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "user_sync_snapshots_delete_own" on public.user_sync_snapshots;
create policy "user_sync_snapshots_delete_own"
on public.user_sync_snapshots
for delete
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "prayer_feed_posts_select_visible" on public.prayer_feed_posts;
create policy "prayer_feed_posts_select_visible"
on public.prayer_feed_posts
for select
to authenticated
using (
  status = 'published'
  or (select auth.uid()) = user_id
);

drop policy if exists "prayer_feed_posts_insert_own" on public.prayer_feed_posts;
create policy "prayer_feed_posts_insert_own"
on public.prayer_feed_posts
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "prayer_feed_posts_update_own" on public.prayer_feed_posts;
create policy "prayer_feed_posts_update_own"
on public.prayer_feed_posts
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "prayer_feed_posts_delete_own" on public.prayer_feed_posts;
create policy "prayer_feed_posts_delete_own"
on public.prayer_feed_posts
for delete
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "creation_feed_posts_select_visible" on public.creation_feed_posts;
create policy "creation_feed_posts_select_visible"
on public.creation_feed_posts
for select
to authenticated
using (
  status = 'published'
  or (select auth.uid()) = user_id
);

drop policy if exists "creation_feed_posts_insert_own" on public.creation_feed_posts;
create policy "creation_feed_posts_insert_own"
on public.creation_feed_posts
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "creation_feed_posts_update_own" on public.creation_feed_posts;
create policy "creation_feed_posts_update_own"
on public.creation_feed_posts
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "creation_feed_posts_delete_own" on public.creation_feed_posts;
create policy "creation_feed_posts_delete_own"
on public.creation_feed_posts
for delete
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "creation_feed_comments_select_visible" on public.creation_feed_comments;
create policy "creation_feed_comments_select_visible"
on public.creation_feed_comments
for select
to authenticated
using (
  exists (
    select 1
    from public.creation_feed_posts posts
    where posts.id = post_id
      and (
        posts.status = 'published'
        or posts.user_id = (select auth.uid())
      )
  )
);

drop policy if exists "creation_feed_comments_insert_own" on public.creation_feed_comments;
create policy "creation_feed_comments_insert_own"
on public.creation_feed_comments
for insert
to authenticated
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1
    from public.creation_feed_posts posts
    where posts.id = post_id
      and (
        posts.status = 'published'
        or posts.user_id = (select auth.uid())
      )
  )
);

drop policy if exists "creation_feed_comments_update_own" on public.creation_feed_comments;
create policy "creation_feed_comments_update_own"
on public.creation_feed_comments
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "creation_feed_comments_delete_own" on public.creation_feed_comments;
create policy "creation_feed_comments_delete_own"
on public.creation_feed_comments
for delete
to authenticated
using ((select auth.uid()) = user_id);

comment on table public.user_sync_snapshots is
'Stores the app''s UserProgressSyncSnapshot as a single JSON document per signed-in user.';

comment on table public.newsletter_subscribers is
'Service-role only table for waitlist/newsletter capture. No client-facing RLS policies are intentionally defined.';
