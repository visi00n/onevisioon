alter table public.profiles
  add column if not exists handle text,
  add column if not exists bio text,
  add column if not exists instagram text,
  add column if not exists x_handle text,
  add column if not exists youtube text,
  add column if not exists country text,
  add column if not exists usa_area_code text,
  add column if not exists small_group_key text;

create table if not exists public.community_messages (
  id uuid primary key default gen_random_uuid(),
  room_key text not null,
  room_title text not null default '',
  user_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null,
  handle text not null,
  body text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint community_messages_body_check check (char_length(trim(body)) > 0)
);

create table if not exists public.community_presence (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  handle text not null default '',
  current_room_key text,
  local_room_key text,
  small_group_key text,
  country text,
  usa_area_code text,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_community_messages_room_created
  on public.community_messages using btree (room_key, created_at desc);

create index if not exists idx_community_messages_user_id
  on public.community_messages using btree (user_id);

create index if not exists idx_community_presence_local_room_key
  on public.community_presence using btree (local_room_key);

create index if not exists idx_community_presence_small_group_key
  on public.community_presence using btree (small_group_key);

create index if not exists idx_community_presence_last_seen_at
  on public.community_presence using btree (last_seen_at desc);

drop trigger if exists trg_community_messages_updated_at on public.community_messages;
create trigger trg_community_messages_updated_at
before update on public.community_messages
for each row
execute procedure public.handle_updated_at();

drop trigger if exists trg_community_presence_updated_at on public.community_presence;
create trigger trg_community_presence_updated_at
before update on public.community_presence
for each row
execute procedure public.handle_updated_at();

grant select on public.community_messages to authenticated;
grant insert, update, delete on public.community_messages to authenticated;
grant select, insert, update, delete on public.community_messages to service_role;

grant select on public.community_presence to authenticated;
grant insert, update, delete on public.community_presence to authenticated;
grant select, insert, update, delete on public.community_presence to service_role;

alter table public.community_messages enable row level security;
alter table public.community_presence enable row level security;

drop policy if exists "community_messages_select_authenticated" on public.community_messages;
create policy "community_messages_select_authenticated"
on public.community_messages
for select
to authenticated
using (true);

drop policy if exists "community_messages_insert_own" on public.community_messages;
create policy "community_messages_insert_own"
on public.community_messages
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "community_messages_update_own" on public.community_messages;
create policy "community_messages_update_own"
on public.community_messages
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "community_messages_delete_own" on public.community_messages;
create policy "community_messages_delete_own"
on public.community_messages
for delete
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "community_presence_select_authenticated" on public.community_presence;
create policy "community_presence_select_authenticated"
on public.community_presence
for select
to authenticated
using (true);

drop policy if exists "community_presence_insert_own" on public.community_presence;
create policy "community_presence_insert_own"
on public.community_presence
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "community_presence_update_own" on public.community_presence;
create policy "community_presence_update_own"
on public.community_presence
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "community_presence_delete_own" on public.community_presence;
create policy "community_presence_delete_own"
on public.community_presence
for delete
to authenticated
using ((select auth.uid()) = user_id);
