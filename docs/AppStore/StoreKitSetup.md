# One Visioon StoreKit Setup

## App Store Payment Path
One Visioon sells digital Bible School access inside the iOS app, so the launch payment path is Apple In-App Purchase with auto-renewable subscriptions.

The app uses StoreKit 2 locally. No Stripe or external payment checkout should be used for Bible School access in the App Store build.

## Subscription Group
- Group name: `Bible School Membership`
- Use one subscription group so monthly and yearly plans are treated as alternatives to the same access level.

## Product IDs
- Monthly product ID: `onevisioon.premium.monthly`
- Yearly product ID: `onevisioon.premium.yearly`

These IDs must match App Store Connect exactly. If they differ by even one character, StoreKit will return no products.

## Pricing
The app no longer hardcodes launch prices. It displays the localized `displayPrice` returned by StoreKit.

Set the official launch prices in App Store Connect. Suggested launch positioning:
- Monthly: choose the intended monthly tier in App Store Connect.
- Yearly: choose the intended yearly tier in App Store Connect.

If the yearly price is lower than paying monthly for 12 months, the app calculates the savings percentage from the live StoreKit prices.

## Optional Introductory Trial
Only configure a trial if you want Apple to offer one.

- If a monthly introductory free trial exists in App Store Connect, the subscription screen can say `Start Bible School Trial`.
- If no free trial exists, the app says `Start Monthly Plan`.
- Do not mention a specific trial length in app copy unless that trial is configured in App Store Connect.

## In-App Copy Mapping
- `Bible Study` = free self-guided path
- `Bible School` = paid subscription path

## What The App Code Expects
- The app loads both product IDs through StoreKit 2.
- Onboarding refreshes products when the membership screen appears.
- The onboarding screen purchases the selected monthly or yearly plan.
- The subscription screen loads products, purchases, and restores purchases.
- Premium gating depends on verified StoreKit entitlements.
- The app listens to transaction updates and refreshes current entitlements.

## App Store Connect Checklist
1. Sign the latest Paid Apps Agreement.
2. Complete banking and tax information.
3. Open App Store Connect.
4. Open `Apps`.
5. Select `One Visioon`.
6. Confirm the app bundle ID is `vsn.onevisioon`.
7. Open `Monetization` -> `Subscriptions`.
8. Create the subscription group `Bible School Membership`.
9. Create monthly subscription `onevisioon.premium.monthly`.
10. Create yearly subscription `onevisioon.premium.yearly`.
11. Add display names, descriptions, localizations, and pricing.
12. Add an introductory offer only if you want a real free trial or launch offer.
13. Add review screenshots and subscription review information when App Store Connect asks for them.
14. Attach the first subscriptions to the same app version submission as the 1.0 build.
15. Test purchases in Sandbox or TestFlight before submitting for review.

## Suggested Product Metadata
Monthly:
- Reference name: `One Visioon Bible School Monthly`
- Display name: `Monthly Bible School`
- Description: `Full Bible School access with deeper chapter lessons, Greek study support, guided paths, and quests.`

Yearly:
- Reference name: `One Visioon Bible School Yearly`
- Display name: `Yearly Bible School`
- Description: `Full Bible School access with deeper chapter lessons, Greek study support, guided paths, and quests.`

## Recommended Review Notes
- `Bible Study` is the free self-guided Bible path.
- `Bible School` is the paid subscription path.
- Onboarding can lead directly into the Bible School purchase flow.
- The app uses StoreKit 2 with these product IDs: `onevisioon.premium.monthly`, `onevisioon.premium.yearly`.
- If App Review needs access, use the sandbox purchase flow or provide an approved review account if Apple requests one.
