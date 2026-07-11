# One Visioon: THE FIRST EDITION

One Visioon is a Bible-centered discipleship app built for Scripture reading, guided Bible School lessons, Greek word study, prayerful reflection, and daily growth.

## First Edition Focus
- Bible reader with highlights, notes, daily verse support, and original-language study.
- Greek study tools for selected verses, including local verse meaning, full gloss range, dictionary form, Strong's number, grammar, pronunciation, and verse context.
- Greek search with tighter matching: primary meanings first, controlled related senses second, and low-signal words like "the" or "and" filtered out.
- Bible School lessons with chapter reading, guided teaching, reflection, sermon depth, Scripture links, history, and quests.
- New Testament lesson folders now include Matthew, Mark, Luke, John, Acts, Romans, 1 Corinthians, and James.
- Bible in a Year now opens its full 12-month checkpoint path.
- Companion, Glorify, Quests, Journey, and growth tracking remain connected to the user's study progress.

## Tutorial Image Assets
Tutorial slides are loaded from the asset catalog:

`/Users/laptcv/Desktop/onevisioon/onevisioon/Assets.xcassets`

Create or replace image sets with these exact names:

- `home1tut`, `home2tut`, `home3tut`
- `glorify1tut`, `glorify2tut`, `glorify3tut`
- `bible1tut`, `bible2tut`, `bible3tut`
- `lessons1tut`, `lessons2tut`, `lessons3tut`
- `chat1tut`, `chat2tut`, `chat3tut`

Recommended image size: `1290x2796` px portrait. Use a white background and keep important text/art inside a centered safe area around `1080x2200` px. The app displays these images full-screen with `scaledToFill`, so edges can crop slightly on different iPhone sizes.

## App Store Notes
- Keep tutorial images clean, high contrast, and away from borders.
- Do not include API keys or private credentials in the repo.
- The Greek tools are study helps and should keep directing users back to verse and chapter context.
- Public legal pages live in `docs/Site`: privacy policy, support, and terms of use.
- The app must only ship the Supabase anon key. Service-role/admin keys belong server-side only.
