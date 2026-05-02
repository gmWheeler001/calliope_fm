# Development Notes

A walkthrough of the thinking, decisions, and process behind building Calliope FM.

---

## The Brief

> "Develop an app which gives the user the ability to listen to radio stations. The user should be able to see a list of all the radio stations and when the user clicks any of them it has to start playing. There must also be controls for the station playing, such as play/pause, volume up/down, etc. If the user likes the station they would be able to mark it as a favourite and access it any time."

**Technical requirements:**
- Pull radio stations from a free API
- Clear instructions for running the application in the README
- Run on iOS or Android

---

## Choosing the Stack

The first task was finding a suitable, openly licensed source of radio station data. After evaluating the API complexity with some AI assistance, I cross-referenced it against existing Flutter packages before committing — no point building around an API if the community has already solved the integration layer. I landed on [Radio Browser](https://www.radio-browser.info/), a community-maintained, free and open database of internet radio stations.

For the audio player I evaluated several packages but settled on **just_audio**. It has the broadest adoption in the Flutter community, solid background playback support, and I had prior familiarity with it — an important factor when working to a deadline.

**State management: Riverpod.** The player alone has enough state (playback status, volume, buffering, errors, sleep timer countdown, skip availability) that a well-structured Riverpod setup removes a significant amount of manual state wiring. It does trade away some of the self-documenting quality of Cubits, but well-named providers and notifiers compensate for that. It also performs better with fine-grained rebuilds.

**Folder structure: feature-first clean architecture.** Each feature is self-contained (`stations`, `player`, `history`, `home`), with shared infrastructure in `core/`. This keeps the codebase navigable as it grows, makes it obvious where new code should live, and isolates changes well.

---

## Feature Planning

Before writing any code I mapped out all the use cases and built a full feature set. In a normal engagement this list would go past product and design for sign-off — confirming everything is technically feasible before it gets committed to a roadmap. It also doubles as a manual test plan and a way to track progress from MVP outward.

After completing most of the list I ran an AI pass to check for gaps. That surfaced two items I hadn't fully considered: the vote button and some clarification around history behaviour.

<details>
<summary>Full feature set</summary>

**Home**
- Search
- Favourites tab (hidden until the user adds their first favourite)
- History — list of past played stations
  - Replayed stations bubble to the top
  - 100 item cap
  - Empty state and loading state

**Filters**
- Genre, country, bitrate, language, popularity

**Station list**
- Pull to refresh
- Infinite scroll (load more on reaching the bottom)
- Per-station: artwork, name
- Featured station hero card at the top of the list
- Loading skeleton and empty state

**Mini player**
- Play/pause, next, previous, favourite
- Volume control (independent of device volume)

**Player screen**
- Play/pause, previous, next
- Volume control (independent of device volume)
- Favourite / unfavourite
- Stream error with retry and auto-skip after 5 seconds
- Loading state
- Vote / thumbs up

**Sleep timer**
- Durations: 5, 10, 30, 60 min
- Gentle fade-out in the final minute
- Countdown visible to the user

**Background playback**
- Audio continues when the screen is locked or another app is in the foreground
- Station artwork shown on the lock screen
- Notification with play/pause, previous, and next controls
</details>

---

## Design Direction

With the feature scope agreed, the next step was establishing a visual direction before writing a line of UI code — both to avoid rework and because in a real project this step requires client and product sign-off.

Starting from Pinterest and AI-assisted mood boarding, and checking current design trends, I settled on a **dark glassmorphism layout** with vibrant purple and pink accents. The goal was something that feels premium without being cold — the warm gradient tones keep the UI inviting even against a near-black background.

---

## Development Stages

Development was sequenced intentionally: **functionality first, then UI and UX polish**. Each stage is small enough to test in isolation before moving on.

1. **Project setup** — fresh Flutter project, removed unused build targets, initialised git, updated `pubspec.yaml` with all required packages, added `UIBackgroundModes` to `Info.plist` for background audio, defined app constants and storage keys, scaffolded the router and base screens, created the first widget test.

2. **Data layer** — `RadioStation` and `StationFilters` models, providers for fetching and filtering stations, unit tests for models and providers.

3. **Station list** — home screen wired to live data, search bar, genre chips, pull-to-refresh, loading skeleton, empty state. Filter sheet was initially a bottom sheet; later folded directly into the home layout for cleaner navigation.

4. **Audio player** — integrated `just_audio` and `just_audio_background`, built `RadioPlayerState` and `PlayerNotifier` with `keepAlive` for background playback and app-resume continuity. All playback controls (play/pause, skip, volume, error handling) live here.

5. **Favourites and history** — history tab with "last listened at" timestamps (useful both as a debug tool and as a UI element), favourites tab hidden until the first favourite is added.

6. **Navigation polish** — added action buttons to supplement the tab bar, which wasn't discoverable enough for first-time users. Animated transitions between tabs. Updated skip/previous controls to disable correctly at playlist boundaries.

7. **Sleep timer** — new action button, countdown message in the player, action sheet for duration selection, gentle volume fade in the final minute.

8. **Code cleanup (AI-assisted)** — fixed comments and variable names, removed structural duplication, consolidated repeated patterns.

9. **Android testing** — first Android device test. Worked through permissions, Gradle configuration, and manifest requirements using the package documentation. UI tweaks across multiple device sizes to ensure consistency.

10. **Platform fixes** — resolved the white flash on launch (Android window theme + Flutter color scheme), corrected the iOS splash screen to dark, removed the onboarding flow (no longer needed), fixed a sleep timer bug where the volume would jump to maximum before fading if the user had already lowered it.

11. **Orientation lock** — portrait only on iPhone. The player and app bar consume too much vertical space in landscape for the layout to work well.

12. **Theme consolidation** — migrated inline styles, magic numbers, and hardcoded colours into `UiConstants` and `AppTheme`. This moved the codebase from "fast prototype" to a maintainable standard. AI was particularly useful here for finding every scattered usage.

13. **Overflow audit** — fixed text truncation across the mini player, station list, and player screen. Added full text-scaling support.

14. **Featured card filter-awareness** — the hero card now hides itself when the featured station doesn't match the active search or genre filter.

15. **App icon** — generated with AI to match the colour scheme: a purple-to-pink radio wave graphic on a dark background.

16. **Final polish** — after extended real-device use, reworked the mini player title (was truncating too aggressively), restored the volume slider as an interactive control, and refined the overall layout.

17. **Documentation** — README and this file.

18. **Last minute fixes** - small fix to bug found during testing where a possible oveerflow can appear in the player screen if all controlls are in use with error

---

## Reflection

I had far more fun on this project than I anticipated — and as I write this, a genuinely good track is playing through it. I'm proud of how it came together: the colours feel right, the music quality is solid, and the interface is simple enough that it just gets out of the way.

This is the kind of project I'll keep coming back to. The road ahead, when time allows:

1. Light mode support
2. Equaliser
3. Better alignment between the background notification and the app's visual identity
4. Animated transition from mini player to full player
5. Animated background blobs
6. Station sharing — deep links so users can send a station to a friend
7. Alarm / wake-up timer
8. Analytics
9. Improved splash screen and launch animations
10. A properly designed logo to replace the AI-generated placeholder

There will be more ideas. There always are.

— Garrick