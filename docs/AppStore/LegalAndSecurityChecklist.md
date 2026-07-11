# Legal And Security Checklist

Last updated: July 2026

This is an engineering checklist, not legal advice. Have a qualified lawyer review the public terms/privacy pages before launch.

## Public URLs
- Privacy Policy: `https://unovisioon.com/privacy-policy`
- Support: `https://unovisioon.com/support`
- Terms of Use: `https://unovisioon.com/terms`
- Apple standard EULA fallback: `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`

## In-App Requirements Covered
- Account screen links to Privacy Policy, Support, and Terms of Use.
- Users can initiate account/data deletion from the Account screen.
- The deletion flow signs the user out, clears local app data, and opens a support email for cloud deletion.
- Sign in UI is Apple-only.
- Premium copy says `$3/month, billed yearly`.
- StoreKit handles payment and subscription management.

## Security Controls In The App
- Sign in with Apple capability is enabled.
- Auth sessions are saved in Keychain, not UserDefaults.
- Supabase configuration rejects placeholder values.
- The app uses the public Supabase anon key only.
- Service-role/admin keys must never ship in the app.
- Supabase database access must stay protected with Row Level Security migrations.
- App Transport Security has no insecure HTTP exception configured.
- No ad SDK, analytics SDK, ATT tracking permission, camera, microphone, or location permission is declared.

## Server-Side Follow-Up Required
- Add a secure Supabase Edge Function or backend endpoint for full account deletion.
- That endpoint should authenticate the user, delete user-owned rows, then delete the Supabase Auth user with a server-side admin key.
- Keep the service-role key only in Supabase secrets or server environment variables.
- Add moderation/reporting workflow before heavily promoting community/chat features.
- Recheck App Store privacy answers whenever data collection changes.
