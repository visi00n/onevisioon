# One Visioon Annual Subscription Setup

## Live Product Model

One Visioon offers one auto-renewable subscription through Apple In-App Purchase:

- Product ID: `onevisioon.premium.yearly`
- Duration: 1 year
- Access: Greek Bible and Greek study tools, Bible notes, Glorify, all available lessons, Freedom, and quests
- Purchase UI: one annual purchase button
- Marketing presentation: the localized annual price divided by 12 is shown as a monthly equivalent; the full annual charge is shown beside the button

The app still recognizes `onevisioon.premium.monthly` in verified entitlements so any existing monthly subscribers keep access, but it does not offer that product to new customers.

## App Store Connect: Exact Setup

1. Sign in to App Store Connect and select **Apps → One Visioon**.
2. Confirm the bundle ID is `vsn.onevisioon`.
3. Open **Monetization → Subscriptions**.
4. Create one subscription group named `One Visioon Premium`. Use only one group.
5. Inside that group, create a subscription:
   - Reference name: `One Visioon Premium Annual`
   - Product ID: `onevisioon.premium.yearly`
   - Duration: `1 Year`
6. Set availability for every storefront where the app will be available.
7. Set the annual price. To market it as approximately `$3/month` in the US storefront, select an annual US price close to `$35.99/year`. The app calculates the localized monthly equivalent from Apple’s live price; it does not hardcode `$3` for every country.
8. Add at least one localization:
   - Display name: `One Visioon Premium Annual`
   - Description: `Greek study, Bible notes, Glorify, lessons, Freedom, and quests.`
9. Under Review Information, upload a screenshot of the in-app paywall showing:
   - the monthly equivalent,
   - the full annual price,
   - the annual purchase button,
   - Restore Purchases,
   - Privacy Policy and Terms of Use.
10. Add review notes explaining where every premium entry point is located.
11. Make sure the subscription status becomes **Ready to Submit**. If it says **Missing Metadata**, open the subscription and complete the highlighted fields.
12. For the first subscription submission, open the new app version page, scroll to **In-App Purchases and Subscriptions**, choose **Select In-App Purchases or Subscriptions**, and attach `onevisioon.premium.yearly` to the version before submitting the app.

Do not create the annual plan as a non-consumable or non-renewing subscription. It must be an **auto-renewable subscription** with a **1 Year** duration.

## What To Do With The Old Monthly Product

- If `onevisioon.premium.monthly` was never approved, do not attach it to the new app version.
- If it is approved and has subscribers, remove it from sale for new customers but do not delete or reuse its ID.
- Existing verified monthly transactions continue to unlock Premium in the app.

The old promotional offer `onevisioon.yearly.special` is not used by the current paywall. Do not configure it unless a future version deliberately brings promotional offers back with the required server-signed flow.

## Required App Store Metadata

Update the App Store description and screenshots so they clearly label premium content. Suggested wording:

> One Visioon is free to open and use for Bible reading, prayer support, and community. One Visioon Premium is an optional annual subscription that unlocks Greek Bible study, Bible notes, Glorify, all available lessons, Freedom, and quests.

Do not advertise premium screens as free. Do not put `$3/month` in the App Store subtitle or app name. Prices in App Store metadata can become inaccurate by storefront; let StoreKit show the customer’s localized price inside the app.

## Suggested App Review Notes

> One Visioon opens directly without onboarding or a required login. Premium is an optional auto-renewable annual subscription purchased with StoreKit 2.
>
> Product ID: `onevisioon.premium.yearly`
>
> Premium entry points: tap the Glorify tab, tap the Lessons tab, tap Greek in the Bible tab, choose the Greek Bible version, open Bible Notes, or select verses and tap Greek Study/Note. Each entry point presents the same annual paywall.
>
> The paywall shows a localized monthly equivalent calculated from the annual StoreKit price, and separately shows the full localized amount billed yearly. There is one purchase button for the annual product, plus Restore Purchases, Privacy Policy, and Terms of Use.
>
> Sign in with Apple is optional and available in Profile. It is not required to purchase or use Premium. Entitlement access comes from verified StoreKit transactions.

## Pre-Submission Test

Test with a Sandbox Apple Account or TestFlight:

1. Fresh install opens Home immediately without onboarding.
2. Glorify and Lessons present the paywall before content appears.
3. Greek Search, Greek Bible, Greek Study, and Bible Notes present the paywall.
4. The paywall loads `onevisioon.premium.yearly` and its localized price.
5. The monthly equivalent equals the annual StoreKit price divided by 12.
6. The purchase sheet identifies a one-year auto-renewable subscription.
7. A successful purchase unlocks all premium entry points without requiring login.
8. Relaunching the app keeps Premium unlocked.
9. Restore Purchases unlocks Premium on a clean install.
10. Cancellation or expiration removes Premium access after the entitlement expires.
11. Privacy Policy and Terms of Use links open successfully.

App Store Connect metadata changes can take up to an hour to appear in Sandbox. If StoreKit returns no product, first check the exact product ID, agreements/tax/banking status, localization, price, availability, and whether the subscription is attached to the submitted version.
