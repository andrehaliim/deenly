# Deenly 🌙

**A companion for the modern Muslim.**

Deenly is an Islamic companion app built with Flutter that helps Muslims fit their daily worship naturally into modern life. It brings accurate, location-based prayer times, the Quran with audio recitation, Qibla direction, morning and evening dhikr, daily duas, a Hijri calendar and zakat calculators together in one calm, carefully designed app, with a home screen widget, reliable reminders and full support for English and Bahasa Indonesia.

<p align="center">
  <img src="docs/hand.png" alt="Deenly home screen held in hand" width="640">
</p>

<p align="center">
  <img src="docs/banner.png" alt="Deenly prayers, Quran and home screen widget" width="640">
</p>

## ✨ Features

### 🕌 Prayer

- **Prayer Times**: Accurate times for your GPS location or a chosen city, with the calculation method and Asr school picked for your country and adjustable per prayer.
- **Prayer Tracker**: Mark each prayer as done, straight from the schedule or from the notification, and look back at your prayer history.
- **Adhan & Reminders**: The adhan plays right at prayer time, with an optional reminder 10 minutes before each prayer and sunrise.
- **Qibla Compass**: Find the Qibla direction from anywhere, with a clear warning on phones without a magnetic sensor.
- **Mosque Finder**: The nearest mosques and prayer rooms within 2 km, with walking directions and a shortcut to search more on Google Maps.

### 📖 Quran

- **Read & Listen**: All 114 surahs in Arabic with English and Indonesian translations, plus verse-by-verse audio recitation.
- **Reading Settings**: Choose your reciter, page color (default, dark, sepia), Arabic and translation text size, and whether to show translations or play ta'awudz and basmala.
- **Continue Reading**: Pick up where you left off and jump straight to any ayah.

### 📿 Daily Worship

- **Morning & Evening Dhikr**: Guided dhikr with a tap counter, progress tracking and timely reminders.
- **Duas**: A collection of daily duas grouped by occasion.
- **Asmaul Husna**: The 99 Names of Allah with their meanings.
- **Tasbih Counter**: A simple digital counter with haptic feedback.
- **Hadith**: A hadith to reflect on, right on the home screen.

### 📅 Calendar & Zakat

- **Hijri Calendar**: Islamic holidays and sunnah fasts (Arafah, Ashura, Ayyam al-Bidh, Monday & Thursday), with reminders the evening before and a manual date adjustment.
- **Zakat Calculators**: Zakat on income, wealth (maal), gold, trade, fitrah and fidyah, with the nisab based on live gold and silver prices, plus a zakat guide and niyyah.

### 📱 And More

- **Home Screen Widget**: The next prayer time at a glance, with a light or dark theme.
- **Light & Dark Mode**: A calm design that follows your preference.
- **English & Bahasa Indonesia**: Fully localized in both languages.
- **Offline Ready**: Prayer times are cached locally (SQLite) and most content ships with the app.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Android)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [sqflite](https://pub.dev/packages/sqflite)
- **Background Tasks**: [WorkManager](https://pub.dev/packages/workmanager)
- **Notifications**: [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- **Location**: [Geolocator](https://pub.dev/packages/geolocator), [Geocoding](https://pub.dev/packages/geocoding)
- **Compass**: [flutter_compass](https://pub.dev/packages/flutter_compass)
- **Audio**: [just_audio](https://pub.dev/packages/just_audio)
- **Home Widget**: [home_widget](https://pub.dev/packages/home_widget)
- **Design**: [Google Fonts](https://pub.dev/packages/google_fonts) (Manrope, Noto Naskh Arabic, Noto Serif), [Font Awesome](https://pub.dev/packages/font_awesome_flutter)
- **i18n**: [Flutter gen-l10n](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) (`intl`)

## 📦 Data Sources

- **Prayer Times**: [Aladhan API](https://aladhan.com/prayer-times-api)
- **Quran Text & Translations**: [quran-api](https://github.com/fawazahmed0/quran-api)
- **Quran Audio**: [EveryAyah](https://everyayah.com/)
- **Mosque Finder**: [Photon](https://photon.komoot.io/) (OpenStreetMap data)
- **Gold & Silver Prices**: [Gold API](https://gold-api.com/), converted with [Frankfurter](https://frankfurter.dev/)
- **Hadith, Duas, Dhikr & Asmaul Husna**: Bundled with the app in `assets/jsons/`

## 🚀 Getting Started

### Prerequisites

- [FVM](https://fvm.app/) (the project pins Flutter 3.47.9 in `.fvmrc`)
- Android Studio or VS Code
- An Android emulator or physical device

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/andrehaliim/deenly.git
   cd deenly
   ```

2. **Install the pinned Flutter version and dependencies:**
   ```bash
   fvm install
   fvm flutter pub get
   ```

3. **Run the application:**
   ```bash
   fvm flutter run
   ```

### Release Build

Release builds are signed with the key in `android/key.properties`. Copy `android/key.properties.example`, fill in your keystore details, then run:

```bash
fvm flutter build appbundle --release
```

Without `key.properties`, release builds fall back to the debug key.

## 📂 Project Structure

```text
lib/
├── components/    # Providers, helpers, theme and shared widgets
├── l10n/          # Localization (English, Bahasa Indonesia)
├── models/        # Data models
├── pages/         # Feature screens (Home, Prayers, Quran, Qibla, Zakat, etc.)
├── proxys/        # Data access layers for APIs and bundled data
└── main.dart      # Application entry point
assets/
├── google_fonts/  # Bundled fonts
├── icon/          # App icons
├── images/        # Images and backgrounds
└── jsons/         # Bundled content (hadith, duas, dhikr, events, etc.)
```

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">
  Built with ❤️ for the Ummah.
</p>
