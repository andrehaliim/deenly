# Deenly - Improvement Todo List

> App is live with real users — prioritize user-facing bugs before
> refactors. Last synced with codebase: 2026-10-13.

## 🚨 Critical (user-facing bugs)
- [x] Fix crash on Home when prayer data fails to load (no internet / GPS off):
      `catch` in `loadPrayerData` sets `_isGettingPrayerData = false`, then
      `build` hits `_location!` / `_prayerModel!` while null
      (`home_page.dart:115-116`). Show an error card + retry when
      there is no cached prayer data.
- [x] Remove hardcoded `Asia/Jakarta` timezone (`main.dart:35`, `:77`).
      `tz.local.name` is also sent as `timezonestring` to Aladhan
      (`prayer_proxy.dart:35`), so users outside WIB get wrong prayer times
      AND wrong notification times. Needs device timezone detection
      (e.g. `flutter_timezone` — new package, ask first).
- [x] Stop showing debug notification `"[$task] Failed"` with raw exception
      text to users when a background task fails (`main.dart` catch block in
      `callbackDispatcher`). Log it instead.
- [x] Fix juz list race: `getSurahList()` and `getJuzList()` run in parallel
      (`quran_page.dart:45-46`), but `getJuzList` → `getSurahById` uses
      `firstWhere` without `orElse` on a possibly empty `_surahList`, so the
      juz list can end up empty/partial. Also clear `_surahJuzList` before
      re-populating to avoid duplicates.
- [x] Add `mounted` check before `Navigator.pushReplacement` in
      `splash_page.dart` (navigates after several `await`s).
- [x] Don't block the app with `NoLocationPage` when GPS is off:
      `requestPermission()` returns `false` when the location service is
      disabled, so splash shows "Location permission denied" even though
      permission is granted, and Retry does nothing while GPS stays off.
      Only block when permission is actually denied. When GPS is off, go to
      `MainPage` and use the last saved location + cached prayer data.
      First launch with GPS off (no cache): fall back to the timezone city
      (e.g. `Asia/Jakarta` → Jakarta), mark it as approximate in the UI,
      and replace it once a real GPS fix succeeds. Also let the user pick
      a city manually (GPS off but internet on). Also move
      `no_location_page.dart` strings to l10n.
- [x] Fix prayer data running out at year change: `fetchYearlyPrayer` only
      fetches `calendar/${now.year}` and only re-runs when location or
      timezone changes, so on Jan 1 `getTodayPrayer()` returns null for
      everyone (error card, no notifications, empty widget). Re-fetch when
      today's data is missing, using GPS or the saved `lat`/`long`, in both
      Home and the background task.

## 🟢 Easiest (minutes each)
- [x] Remove stray `;` after `lightSurface` color in `colors.xml` (line 7)
- [x] Add contact email/handle to Nominatim `User-Agent` header in
      `mosque_proxy.dart` (currently `'DeenlyApp/1.0'`)
- [x] Verify `example_appwidget_preview` drawable exists (referenced in
      `deenly_widget_info.xml`)
- [x] Delete or rewrite `test/widget_test.dart` (currently the unused counter
      template)
- [x] Move `flutter_launcher_icons` from `dependencies` to `dev_dependencies`
- [x] Remove duplicate `dailyTaskName` constant (defined in both `main.dart`
      and `workmanager_helper.dart`)
- [x] Replace hardcoded splash background `Color(0xfffafaf7)` with theme color

## 🟡 Easy-medium (localization strings)
- [x] Add `assalamuAlaikum` key to `.arb` files, use in `home_page.dart:120`
- [x] Add `noMosqueFound` key to `.arb` files, use in `mosque_page.dart:99`
- [x] Add `couldNotOpenMaps` key to `.arb` files, use in `mosque_page.dart:74`
- [x] Add `notificationScheduleFailed` key to `.arb` files, use in
      `drawer_page.dart` (repeated 5x for each prayer)
- [x] Add `reminderEnableFailed` key to `.arb` files, use in
      `drawer_page.dart:345` (currently `'Could not enable reminder'`)

## 🟠 Medium (logic / config checks)
- [x] Confirm `ACCESS_BACKGROUND_LOCATION` is NOT declared in
      `AndroidManifest.xml`
- [x] Confirm `POST_NOTIFICATIONS` permission is declared for Android 13+

## 🟣 Later
- [ ] Calculate prayer times on-device (Kemenag: Fajr 20°, Isha 18°)
      instead of fetching yearly data from Aladhan, so the app works fully
      offline, including first launch with GPS and data off. Decide between
      the `adhan` package (new package, ask first) or an own implementation,
      and compare the results against the current Aladhan output.

## 🔵 Dio + Riverpod migration (do in order, not started)
- [ ] Step 1: Add `dio`/`riverpod` deps (ask first), create `dio_client.dart`,
      wrap `main.dart` in `ProviderScope`
- [ ] Step 2: Convert `mosque_proxy.dart` http calls → Dio
- [ ] Step 3: Convert `prayer_proxy.dart` http calls → Dio
- [ ] Step 4: Convert `surah_provider.dart` http calls → Dio
- [ ] Step 5: Convert `ThemeProvider` → Riverpod `@riverpod` notifier
- [ ] Step 6: Convert `DrawerProvider` → Riverpod `@riverpod` notifier
- [ ] Step 7: Convert `LocaleProvider` → Riverpod `@riverpod` notifier
- [ ] Step 8: Convert `AudioProvider` → Riverpod `@riverpod` notifier
- [ ] Step 9: Convert `SurahProvider` → Riverpod `@riverpod` notifier
      (biggest one — network + DB + state)
- [ ] Step 10: Update all widgets from `context.watch<X>()`/`Provider.of` →
      `ConsumerWidget` + `ref.watch()`
- [ ] Step 11: Remove `MultiProvider` wrapper and `provider` package from
      `pubspec.yaml`

## 🔴 Larger structural refactors
- [x] Replace the 5 copy-pasted `_buildPrayerNotificationSetting(...)` calls
      in `drawer_page.dart` (lines ~190-282) with a list-driven widget
- [x] Same for the 5 `_buildPrayerTimeAdjustment(...)` calls (lines ~383-416)
- [x] Extract `_buildTitle`, `_buildPrayerNotificationSetting` and
      `_buildPrayerTimeAdjustment` from `drawer_page.dart` into their own
      widget files
- [ ] Move `SurahDetailList` and `SurahOptionsPanel` out of
      `quran_detail_page.dart` into their own files (classes already
      separated, just still in one file)
- [ ] Gradually align legacy code with `CLAUDE.md` style rules (remove `!`,
      hardcoded strings/colors, lines > 80 chars)

## 📋 Pre-publish checklist (not code)
- [x] Write a privacy policy (required for location permission) —
      page added in `newporto` repo at `/projects/deenly/privacy`,
      linked from the drawer
- [ ] Deploy the `newporto` privacy page (commit + push to Vercel)
- [ ] Add privacy policy URL to Play Console listing
