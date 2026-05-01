# One Visioon App Privacy Answers For Version 1.0

## Current Recommendation
If version 1.0 ships with local-only storage, Sign in with Apple kept on-device, no analytics SDK, no backend account system, and no newsletter submission backend, the safest App Privacy answer is still:

- `Data Not Collected`

## Why
- Name, email, Apple sign-in identity, notes, highlights, streaks, and lesson progress are currently stored on-device in local app storage.
- The app does not currently send those fields to your server or a third-party partner.
- StoreKit purchases are handled by Apple.
- Opening Discord or Instagram sends the user to those external services, but the app itself is not collecting that data.

## This Must Change If You Add Any Of The Following
- Cloud sync / backend profiles
- Newsletter signup delivery
- Analytics SDKs
- Crash reporting SDKs
- In-app community posting

If any of those are added, or if Apple sign-in data starts being transmitted to your backend, revisit the App Privacy questionnaire before submission.

## Where To Fill This In
App Store Connect:
1. Open `Apps`
2. Select `One Visioon`
3. Open `App Information`
4. Open the `App Privacy` section
5. Complete the questionnaire there
