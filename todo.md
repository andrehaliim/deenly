# Deenly - Improvement Todo List

## 🟢 Easiest (minutes each)
- [ ] Remove stray `;` after `lightSurface` color in `colors.xml`
- [ ] Add contact email/handle to Nominatim `User-Agent` header in `mosque_proxy.dart`
- [ ] Verify `example_appwidget_preview` drawable exists (referenced in `deenly_widget_info.xml`)
- [ ] Delete or rewrite `test/widget_test.dart` (currently the unused counter template)

## 🟡 Easy-medium (localization strings)
- [ ] Add `assalamuAlaikum` key to `.arb` files, use in `home_page.dart`
- [ ] Add `noMosqueFound` key to `.arb` files, use in `mosque_page.dart`
- [ ] Add `couldNotOpenMaps` key to `.arb` files, use in `mosque_page.dart`
- [ ] Add `notificationScheduleFailed` key to `.arb` files, use in `drawer_page.dart`
- [ ] Add `reminderEnableFailed` key to `.arb` files, use in `drawer_page.dart`

## 🟠 Medium (logic fixes)
- [ ] Add `_hasError` state + retry UI in `home_page.dart` to prevent null-assert crash on `_prayerModel!`/`_location!`
- [ ] Confirm `ACCESS_BACKGROUND_LOCATION` is NOT declared in `AndroidManifest.xml`
- [ ] Confirm `POST_NOTIFICATIONS` permission is declared for Android 13+

## 🔵 Dio + Riverpod migration (do in order)
- [ ] Step 1: Add `dio`/`riverpod` deps, create `dio_client.dart`, wrap `main.dart` in `ProviderScope`
- [ ] Step 2: Convert `mosque_proxy.dart` http calls → Dio
- [ ] Step 3: Convert `prayer_proxy.dart` http calls → Dio
- [ ] Step 4: Convert `surah_provider.dart` http calls → Dio
- [ ] Step 5: Convert `ThemeProvider` → Riverpod `@riverpod` notifier
- [ ] Step 6: Convert `DrawerProvider` → Riverpod `@riverpod` notifier
- [ ] Step 7: Convert `LocaleProvider` → Riverpod `@riverpod` notifier
- [ ] Step 8: Convert `AudioProvider` → Riverpod `@riverpod` notifier
- [ ] Step 9: Convert `SurahProvider` → Riverpod `@riverpod` notifier (biggest one — network + DB + state)
- [ ] Step 10: Update all widgets from `context.watch<X>()`/`Provider.of` → `ConsumerWidget` + `ref.watch()`
- [ ] Step 11: Remove `MultiProvider` wrapper and `provider` package from `pubspec.yaml`

## 🔴 Larger structural refactors
- [ ] Extract prayer notification toggle loop in `drawer_page.dart` into a reusable list-driven widget
- [ ] Split `quran_detail_page.dart` into separate files: `QuranDetailPage`, `SurahDetailList`, `SurahOptionsPanel`
- [ ] Extract `_buildPrayerNotificationSetting` and `_buildPrayerTimeAdjustment` from `drawer_page.dart` into their own widget files

## 📋 Pre-publish checklist (not code)
- [ ] Write and host a privacy policy (required for location permission)
- [ ] Add privacy policy URL to Play Console listing