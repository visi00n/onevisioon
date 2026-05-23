# One Visioon RLS Security Plan

This app is still local-first today. There is no live server database in the iOS project yet, so true Row Level Security cannot be enforced on-device.

To prepare the backend correctly, the repository now includes a Supabase migration at:

- `/Users/laptcv/Desktop/onevisioon/supabase/migrations/20260514_initial_rls.sql`

## What the migration sets up

- `public.profiles`
  - One row per authenticated user.
  - Users can read their own row.
  - Users can optionally expose their row publicly with `is_public = true`.
  - Users can only insert or update their own row.

- `public.user_sync_snapshots`
  - One row per authenticated user.
  - Stores the app's `UserProgressSyncSnapshot` as JSON.
  - Users can only read, write, update, or delete their own snapshot.

- `public.prayer_feed_posts`
  - Community-ready table for prayer posts.
  - Authenticated users can read published posts.
  - Users can create, update, and delete only their own posts.
  - Hidden posts remain visible only to their owners.

- `public.creation_feed_posts`
  - Community-ready table for the Glorify creation feed.
  - Authenticated users can read published posts.
  - Users can create, update, and delete only their own posts.
  - Hidden posts remain visible only to their owners.

- `public.creation_feed_comments`
  - Comments on creation feed posts.
  - Users can comment only as themselves.
  - Comments are readable only when the related post is visible to the current user.

- `public.newsletter_subscribers`
  - Service-role only table for waitlist/newsletter capture.
  - No client-facing RLS policies are defined on purpose.

## Security choices baked in

- Every policy uses `to authenticated` so unauthenticated users never evaluate row checks.
- Policies use `(select auth.uid())` instead of raw `auth.uid()` to match Supabase's current performance guidance.
- `auth.users` is referenced only by primary key with `on delete cascade`.
- The migration includes `updated_at` triggers and a `handle_new_user()` trigger to create or refresh `public.profiles`.
- The client should only ever use the public `anon` key plus a signed-in user session.
- The `service_role` key must stay server-side only and must never ship in the iOS app.

## How this maps to the current app

- `UserProgressSyncSnapshot` already exists in:
  - `/Users/laptcv/Desktop/onevisioon/onevisioon/Models/AuthSyncModels.swift`
- Local auth currently exists only as device-level Apple sign-in in:
  - `/Users/laptcv/Desktop/onevisioon/onevisioon/Services/AuthSessionManager.swift`
- Once Supabase Auth is added, the app can sync the existing local snapshot into `public.user_sync_snapshots.snapshot`.

## Next backend steps

1. Create a Supabase project.
2. Run the migration in the Supabase SQL editor or via Supabase migrations.
3. Enable Supabase Auth and configure Apple as a provider.
4. Replace local-only sync with authenticated writes to `public.user_sync_snapshots`.
5. Add server-side endpoints or Edge Functions for privileged operations such as newsletter capture, moderation, or admin review.
6. Add Storage bucket policies later if Glorify image uploads move off-device.

## Important note

This adds the backend security scaffold only. It does not yet switch the iOS app to Supabase or activate remote sync/community features.
