# OVO Clone — Production-Grade Digital Wallet Application

A high-fidelity clone of the OVO Digital Wallet application built with Flutter. This project demonstrates industry-standard mobile engineering practices, including structured Clean Architecture, reactive state management using Provider, local data persistence, advanced security locks, and a premium interactive finance trading dashboard.

---

## 📸 Recommended Screenshots for Portfolio Showcase
To present this project at a professional standard, compile screenshots of the following features:
1. **Interactive Finance Chart**: Showing the volatile line chart with the vertical pointer and tooltip active on a user drag.
2. **App Inactivity Lock**: The fullscreen non-dismissible `PinLockScreen` blocking the app.
3. **Dynamic Dark Mode**: A side-by-side comparison of the Home or Profile screen in both Light and Dark modes.
4. **Live Customer Service Chat**: Conversation thread displaying chat bubbles with checkmark delivery indicators (`sending`, `sent`, `read`).
5. **QR Pay Viewfinder**: The camera interface overlay displaying the corner alignment brackets and "Simulasi Scan" bottom sheet.

---

## 🌟 Key Features

* **Advanced Theming & Dark Mode**: Seamlessly toggle between Light and Dark mode from the Profile settings, persisted using `SharedPreferences`.
* **State Management**: Reactive state handling using `Provider` for authentication, balance deductions/refunds, transaction logging, and chat history.
* **Personal Finance Dashboard**: A premium dashboard featuring a custom Bezier spline area chart representing volatile daily spending, vertical touch-tracker lines, dynamic tooltips, a progress bar budget tracker, and spending category summaries.
* **Chat & Message Status**: Real-time communication simulator with a Customer Service representative, displaying message statuses (`sending`, `sent`, `read`) and automatic replies after a 1.5s simulated network delay.
* **Security & Cooldown Locks**: 
  - 3 incorrect PIN inputs trigger a **30-second cooldown** lock.
  - 5 incorrect attempts trigger a **permanent account lockout** saved locally.
  - App background timeout: If the app remains in the background for **more than 300 seconds**, it automatically presents the un-dismissible `PinLockScreen` upon resume.
* **QR Camera Scanner**: Real camera feed integration using `mobile_scanner` with a "Simulasi Scan QR" fallback bottom sheet containing dummy merchants for simulator testing.

---

## 🏗️ Architecture Design

The project strictly follows **Clean Architecture** patterns to ensure scalability, testability, and separation of concerns:

```
lib/
├── app/
│   ├── themes/         # Light & Dark ThemeData parameters
│   └── routes/         # Dynamic Named Routes and screen generators
├── core/
│   ├── constants/      # AppConstants & DummyData
│   ├── errors/         # Custom Exceptions (e.g. InsufficientBalanceException)
│   ├── extensions/     # Capitalize, masking, and formatting helpers
│   ├── providers/      # State Notifiers (Auth, Balance, Transaction, Chat, Theme)
│   ├── services/       # Mock authentication and transaction logic
│   └── utils/          # Currency formatters & Validators
├── data/
│   └── models/         # UserModel, TransactionModel, ChatMessage, etc.
└── presentation/
    ├── screens/        # UI Screen layers (Splash, Onboarding, Home, Finance, etc.)
    └── widgets/        # Reusable component libraries (Buttons, Cards, TextFields)
```

---

## 🛠️ Tech Stack & Libraries Used

This project leverages standard production-ready Flutter libraries:

* **State Management**: [Provider](https://pub.dev/packages/provider) `^6.1.2`
* **Local Persistence**: [SharedPreferences](https://pub.dev/packages/shared_preferences) `^2.2.3`
* **QR Scanning**: [MobileScanner](https://pub.dev/packages/mobile_scanner) `^5.0.0`
* **QR Rendering**: [QrFlutter](https://pub.dev/packages/qr_flutter) `^4.1.0`
* **Typography**: [GoogleFonts (Plus Jakarta Sans)](https://pub.dev/packages/google_fonts) `^6.2.1`
* **UI Indicators**: [SmoothPageIndicator](https://pub.dev/packages/smooth_page_indicator) `^1.1.0`
* **Localization & Formatting**: [Intl](https://pub.dev/packages/intl) `^0.19.0`

---

## 💻 Environment & Flutter SDK

```yaml
Flutter SDK: 3.41.7
Channel: stable
Engine Hash: 7a53c052bc4b472cf780b199087e1368e4a9aa8c
Tools: Dart 3.11.5, DevTools 2.54.2
```

---

## 🚀 Getting Started

Follow these steps to run the OVO Clone locally on your system:

### 1. Clone the repository
```bash
git clone https://github.com/WagyuuA5/ovo_clone.git
cd ovo_clone
```

### 2. Fetch dependencies
Ensure your environment supports Flutter `3.x` before fetching:
```bash
flutter pub get
```

### 3. Run the project
To run on your web browser or connected emulator:
```bash
flutter run -d chrome
```

---

## 📄 License & Copyright

```
Copyright © 2026 Wahyu Ravi Anggoro — @WagyuuA5
Student at SMK Telkom Malang 2026. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
