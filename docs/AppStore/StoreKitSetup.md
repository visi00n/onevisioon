# One Visioon StoreKit Setup

## Subscription Group
- Group name: `Bible School`

## Product IDs
- Monthly: `onevisioon.premium.monthly`
- Yearly: `onevisioon.premium.yearly`

## Launch Prices
- Monthly: `$15`
- Yearly: `$80`

## In-App Copy Mapping
- `Bible Study` = self-guided path
- `Bible School` = paid subscription path

## What The App Code Already Expects
- The app loads both product IDs through StoreKit 2.
- The onboarding screen can now attempt purchase when a user finishes setup after choosing Bible School.
- The subscription screen can load products, purchase, and restore purchases.
- Premium gating now depends on live StoreKit entitlements instead of preview mode.

## App Store Connect Steps
1. Open `App Store Connect`
2. Open `Apps`
3. Select `One Visioon`
4. Open `Subscriptions`
5. Create one auto-renewable subscription group named `Bible School`
6. Add the monthly product with ID `onevisioon.premium.monthly`
7. Add the yearly product with ID `onevisioon.premium.yearly`
8. Set the pricing to match `$15/month` and `$80/year`
9. Add subscription review screenshots and text
10. Make sure both products are attached to the app version you submit

## Recommended Review Notes
- Explain that `Bible School` is the paid path and `Bible Study` is the self-guided path.
- Mention that onboarding can lead directly into the Bible School purchase flow.
- Mention the exact product IDs used by the app.
