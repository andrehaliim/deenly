# Deenly 🌙

Deenly is a premium, feature-rich Islamic companion app built with Flutter. It's designed to help Muslims integrate their spiritual practice seamlessly into their modern lives with a stunning user interface and reliable functionality.

![Deenly Header](assets/images/logo.png)

## ✨ Features

- **📍 Precise Prayer Times**: Automatically calculates accurate prayer times based on your current geographical location.
- **🧭 Qibla Compass**: A beautiful and accurate compass to help you find the Qibla direction from anywhere in the world.
- **📖 Digital Quran**: Read and reflect on the Holy Quran with a clean, readable interface.
- **📿 Tasbih Counter**: A simple yet elegant digital counter for your daily Adhkar and Dhikr.
- **🕌 Mosque Finder**: Find nearby mosques and prayer spaces quickly.
- **🔔 Adhan Notifications**: Never miss a prayer with customizable reminders and Adhan alerts.
- **📱 Home Screen Widget**: Keep track of the next prayer time at a glance with a native home screen widget.
- **🌓 Dynamic UI**: Supports both Light and Dark modes with a premium aesthetic.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [SQFlite](https://pub.dev/packages/sqflite)
- **Background Tasks**: [WorkManager](https://pub.dev/packages/workmanager)
- **Notifications**: [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- **Location Services**: [Geolocator](https://pub.dev/packages/geolocator)
- **Design**: [Google Fonts](https://fonts.google.com/), [Lucide Icons](https://lucide.dev/) (via FontAwesome)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Android/iOS Emulator or Physical Device

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/deenly.git
   cd deenly
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── components/    # Reusable UI widgets and helper classes
├── models/        # Data models
├── pages/         # Feature screens (Home, Quran, Qibla, etc.)
├── proxys/        # Data access layers / Proxies
├── tables/        # Database table definitions
└── main.dart      # Application entry point
```

## 🤝 Contributing

Contributions are welcome! If you have ideas for new features or find any issues, please open an issue or submit a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">
  Built with ❤️ for the Ummah.
</p>
