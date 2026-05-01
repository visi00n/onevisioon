# One Visioon App Store Screenshots + Usage Guide

This document gives you:

1. A clear screenshot storyboard for the App Store.
2. Exact capture steps for iPhone/iPad screenshots.
3. "How to use the app" messaging you can reuse in App Store text, landing pages, and social posts.

## 1) App Story In 10 Screenshots (iPhone)

Use these in order so the product narrative is clear and conversion-friendly.

1. Onboarding intro
- Screen: Onboarding first page (`Biblical Learning / Before you start`).
- Overlay title: `End Up With God, One Lesson at a Time`
- Overlay subtitle: `Start with 9 setup questions for a personalized biblical growth path.`

2. Username + identity
- Screen: Onboarding username step (`Choose your username` + live `@handle` preview).
- Overlay title: `Build Your Christian Learning Identity`
- Overlay subtitle: `Create your unique @ to join prayer feed and community growth.`

3. Subscription gate
- Screen: Premium gate (`3-day free trial` CTA visible).
- Overlay title: `Try Premium Free for 3 Days`
- Overlay subtitle: `Unlock full biblical learning, lessons, quests, and daily growth tracking.`

4. Learn home + streak
- Screen: Learn tab top area showing streak pill, progress, points, and level.
- Overlay title: `Track Daily Streak and Growth`
- Overlay subtitle: `Stay consistent with streaks, levels, and wisdom points.`

5. Wisdom folder roadmap
- Screen: Wisdom folder lesson list with lock/unlock progression.
- Overlay title: `Structured Learning Path`
- Overlay subtitle: `Lessons unlock in order after completion and quest pass.`

6. Lesson slide depth
- Screen: Lesson slide showing verse support, written about, summary, deeper meaning.
- Overlay title: `Understand Scripture Clearly`
- Overlay subtitle: `Every slide includes biblical support and practical explanation.`

7. Notes in lesson
- Screen: Lesson notes template open, with save CTA visible.
- Overlay title: `Capture Notes That Matter`
- Overlay subtitle: `Take structured notes and revisit them later in your profile.`

8. Quest challenge
- Screen: Quest question with options and pass score visible.
- Overlay title: `Test What You Learned`
- Overlay subtitle: `Pass quests to unlock next lessons and strengthen retention.`

9. Prayer feed community
- Screen: Prayer Feed with post composer and community posts.
- Overlay title: `Grow with a Prayer Community`
- Overlay subtitle: `Share prayer requests and pray for other believers daily.`

10. Profile + leaderboard
- Screen: Profile with progress + leaderboard section.
- Overlay title: `See Your Progress and Rank`
- Overlay subtitle: `Track lessons, points, level, and public testimony settings.`

## 2) Optional iPad Shot Set (If You Ship iPad)

Reuse the same narrative in 5-8 screenshots:

1. Learn dashboard
2. Wisdom folder lessons
3. Lesson slide + notes
4. Quest screen
5. Prayer feed
6. Profile + leaderboard

## 3) Apple Screenshot Rules To Respect

Current App Store Connect guidance (verify before final upload):

- You can upload a minimum of 1 and maximum of 10 screenshots per device class.
- If UI is the same across sizes/localizations, provide highest required resolution only.
- iPhone screenshot requirements support the newer 6.9-inch set (or 6.5-inch fallback).
- If app supports iPad, provide iPad screenshots as required.

Official references:
- https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
- https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- https://developer.apple.com/news/?id=vgxax6xf

## 4) Capture Workflow (Simulator)

Use this repeatable flow for clean, consistent screenshots:

1. Build and run app in a target Simulator.
2. Force status bar to a clean marketing style (`9:41`, full battery, strong signal).
3. Navigate to each screen in the storyboard.
4. Capture and save with ordered filenames.
5. Add text overlays in Figma/Canva/Photoshop (keep in-app content readable).

### Key commands

Boot device:

```bash
xcrun simctl boot "iPhone 17 Pro Max"
```

Set clean status bar:

```bash
xcrun simctl status_bar booted override \
  --time 9:41 \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100
```

Take screenshot:

```bash
xcrun simctl io booted screenshot "/absolute/path/shot-01-onboarding.png"
```

Clear status bar override after finishing:

```bash
xcrun simctl status_bar booted clear
```

## 5) "How To Use One Visioon" (App Messaging)

Use this exact user journey in your listing and onboarding copy:

1. Complete onboarding setup.
- Answer the setup questions so the app personalizes your biblical growth path.

2. Activate premium access.
- Start the 3-day trial and unlock full learning features.

3. Learn one lesson at a time.
- Open the Wisdom folder, study slides, and review verse-backed explanations.

4. Save structured notes.
- Capture insights inside the lesson and revisit them in Profile > Saved notes.

5. Pass the quest.
- Complete the lesson quiz above passing score to unlock the next lesson.

6. Apply daily wisdom.
- Use the daily tracker to log what you learned and how you will apply it.

7. Stay consistent.
- Keep your streak alive, monitor your level, and grow points over time.

8. Grow in community.
- Post prayer requests and encourage others in the Prayer Feed.

## 6) Design Standards For Screenshot Overlays

Keep screenshots high-conversion and clean:

- One headline + one short subline per screenshot.
- Use black/dark text on light backgrounds for readability.
- Highlight one core value per screen (avoid feature overload).
- Keep text outside key UI controls.
- Maintain a consistent style across all 10 images.

