# Calliope FM

A clean, dark-themed internet radio browser and player for iOS and Android. Browse thousands of stations by genre, search by artist or country, and listen with a persistent background player that keeps going while you use other apps.

---

## Features

- **Browse & search** — find stations by name, artist, genre, or country
- **Genre chips** — one-tap filtering across 20+ genres
- **Featured station** — a curated hero card surfaces the top-voted station matching your current search
- **Background playback** — audio continues when you lock your screen or switch apps
- **Lock-screen controls** — play, pause, and skip from the notification shade or lock screen
- **Dedicated volume control** — the mini player's volume slider adjusts stream volume independently of your device's media volume, so you can set the perfect level without touching your ringer or system audio
- **Sleep timer** — set a countdown (15 / 30 / 45 / 60 / 90 min) and the stream fades out gently before stopping
- **History** — every station you play is saved so you can pick up where you left off
- **Auto-skip** — if a stream fails, the app counts down and skips to the next station automatically

---

## Using the App

### Finding a Station

1. Open the **Stations** tab
2. Type in the search bar — matches on station name, genre, or country
3. Tap a **genre chip** to filter (tap again to deselect; tap **All** to reset)
4. The **featured card** at the top shows the highest-voted station that matches your current search and filter

### Playing a Station

- Tap any station card to start playing immediately and the full player is opened
- The **mini player** appears at the bottom of the stations tab — tap it to open the full player
- Use **skip previous / skip next** to move through stations from the same list you browsed from

### Volume Control

The volume slider in the mini player controls the **stream volume** independently of your device volume. This means you can:

- Turn the stream down without silencing notifications or other apps
- Set a comfortable background level and let your device volume stay unchanged
- Adjust it any time from the full player screen as well

### Sleep Timer

1. Open the full player screen
2. Tap the **moon icon** in the top-right
3. Choose a duration — the stream will gradually fade out and stop when the timer ends
4. Tap **Cancel timer** to dismiss it early

### History

Switch to the **History** tab to see every station you've played, ordered by most recent. Tap any entry to resume playback instantly.

---

## How It Was Built

For a full walkthrough of the thinking, stack decisions, feature planning, and development stages, see [DEVELOPMENT.md](DEVELOPMENT.md).

---

## Building

Requires Flutter 3.x and Dart 3.x.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The app targets **iOS 14+** and **Android API 21+**. Orientations are locked to portrait on iPhone; iPad supports all orientations.