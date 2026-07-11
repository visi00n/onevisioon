# One Visioon App Privacy Answers For Version 1.0

## Current Recommendation
Version 1.0 now includes Sign in with Apple, optional Supabase-backed cloud sync, community/profile features, and StoreKit purchases. Do not answer `Data Not Collected` if the submitted build has Supabase/cloud or community features enabled.

Use App Store Connect's questionnaire to disclose the data types the app can collect or sync, including:
- Contact info: name and email if provided by the user or Apple
- User ID: Apple/Supabase account identifiers
- User content: notes, highlights, reflections, posts, comments, chat messages, and profile content
- Usage data/product interaction: reading progress, lesson progress, streaks, activity days, and selected study path
- Purchases: subscription status is handled by Apple StoreKit

## Why
- The app can sync user profile and study data with Supabase after Sign in with Apple.
- StoreKit purchases are handled by Apple, but the app uses purchase entitlement status to unlock Premium.
- Opening Discord or Instagram sends the user to those external services, but the app itself is not collecting that data.
- The app does not include third-party analytics SDKs, advertising SDKs, sale of personal data, background location tracking, or advertising tracking.

## This Must Change If You Add Any Of The Following
- Newsletter signup delivery
- Analytics SDKs
- Crash reporting SDKs
- Any new third-party SDK
- Any tracking or advertising use

If any of those are added, revisit the App Privacy questionnaire before submission.

## Where To Fill This In
App Store Connect:
1. Open `Apps`
2. Select `One Visioon`
3. Open `App Information`
4. Open the `App Privacy` section
5. Complete the questionnaire there
