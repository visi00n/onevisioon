# Google Auth Setup

One Visioon now supports Google sign-in through Supabase OAuth.

## App redirect URL

The app registers a custom URL scheme based on the bundle identifier:

- Bundle identifier: `vsn.onevisioon`
- App redirect URL: `vsn.onevisioon://auth`

If the bundle identifier changes later, update the redirect URL to match.

## Xcode / app configuration

These files now contain the Google auth client flow:

- `AppInfo.plist`
- `onevisioon/Services/AuthSessionManager.swift`
- `onevisioon/Services/SupabaseAuthClient.swift`
- `onevisioon/Resources/SupabaseConfig.plist`

## Supabase setup

1. Open your Supabase project.
2. Go to `Auth` -> `URL Configuration`.
3. Add `vsn.onevisioon://auth` to the allowed redirect URLs.
4. Go to `Auth` -> `Providers` -> `Google`.
5. Enable the provider.
6. Paste the Google client ID and client secret from Google Cloud.

## Google Cloud setup

1. Create a Google OAuth client.
2. Use `Web application` as the client type.
3. In `Authorized redirect URIs`, add the exact callback URL shown on the Supabase Google provider page.
4. Save the client ID and client secret.
5. Paste them back into Supabase.

## Local app secrets

Fill in the placeholders in:

- `onevisioon/Resources/SupabaseConfig.plist`

Required values:

- `projectURL`
- `anonKey`

## Verification

Verified locally:

- `xcodebuild` simulator build succeeds
- app launches in `iPhone Air` simulator
- Google sign-in button is live in onboarding and profile/account surfaces
