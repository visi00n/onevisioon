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

## Promotional Offer IDs
- Yearly special offer ID: `onevisioon.yearly.special`

This is a promotional offer identifier under the yearly subscription. It is not a third product ID and should not be added to the StoreKit product list.

## Pricing
The app no longer hardcodes launch prices. It displays the localized `displayPrice` returned by StoreKit.

Set the official launch prices in App Store Connect. Suggested launch positioning:
- Monthly: choose the intended monthly tier in App Store Connect.
- Yearly: choose the intended yearly tier in App Store Connect.

If the yearly price is lower than paying monthly for 12 months, the app calculates the savings percentage from the live StoreKit prices.

For the special yearly offer:
- Configure it under `onevisioon.premium.yearly`.
- Reference name: `Yearly Special Offer`
- Promotional offer identifier: `onevisioon.yearly.special`
- Intended offer: yearly Bible School access billed annually at the special launch price you set in App Store Connect.
- If this is meant for all brand-new subscribers, consider using an introductory offer instead of a promotional offer. Promotional offers require a signed purchase option from the app's server.

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
- The onboarding screen purchases the selected monthly, yearly, or eligible yearly special offer plan.
- The subscription screen loads products, purchases, and restores purchases.
- Premium gating depends on verified StoreKit entitlements.
- The app listens to transaction updates and refreshes current entitlements.
- The yearly special offer is shown only when StoreKit returns `onevisioon.yearly.special` for the yearly product and the Supabase signing client is configured.
- The yearly special offer purchase path calls a secure Supabase Edge Function for Apple's signed compact JWS.

## Promotional Offer Signing Endpoint
Apple promotional offers must be signed on a server. Do not put the App Store Connect private key in the iOS app.

The app calls this Supabase Edge Function:

- Function name: `storekit-promotional-offer-signature`
- URL path: `/functions/v1/storekit-promotional-offer-signature`
- Method: `POST`
- Request body:

```json
{
  "product_id": "onevisioon.premium.yearly",
  "offer_id": "onevisioon.yearly.special"
}
```

- Response body:

```json
{
  "compact_jws": "<apple-signed-promotional-offer-jws>"
}
```

The Edge Function should use App Store Connect In-App Purchase signing credentials stored as Supabase secrets. Required secrets depend on the signing implementation, but keep the private key server-only.

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
11. Under the yearly subscription, create promotional offer `onevisioon.yearly.special` only if you want the special signed-offer path.
12. Add display names, descriptions, localizations, and pricing.
13. Add an introductory offer only if you want a real free trial or new-subscriber launch offer.
14. Deploy the promotional offer signing Edge Function before enabling the special offer card in production.
15. Add review screenshots and subscription review information when App Store Connect asks for them.
16. Attach the first subscriptions to the same app version submission as the 1.0 build.
17. Test normal purchases and the special offer purchase in Sandbox or TestFlight before submitting for review.

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
- The special yearly offer uses promotional offer ID `onevisioon.yearly.special` under the yearly subscription.
- If App Review needs access, use the sandbox purchase flow or provide an approved review account if Apple requests one.
