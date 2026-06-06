<div align="center">
  <h1>💜 OVO Clone — Digital Wallet Application</h1>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41.7-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.11.5-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey?style=for-the-badge&logo=flutter" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-purple?style=for-the-badge" />
</p>

<p align="center">
  A production-grade, high-fidelity clone of the <strong>OVO Digital Wallet</strong> built with Flutter —
  featuring Clean Architecture, advanced security locks, real-time chat simulation, QR scanner, and a premium finance dashboard.
</p>

---

## 📱 Overview

**OVO Clone** is a full-featured digital wallet application that replicates the core experience of the OVO platform. It demonstrates industry-standard mobile engineering practices including structured Clean Architecture, reactive state management with Provider, local data persistence, advanced security mechanisms, and an interactive finance trading dashboard.

---

## ✨ Key Features

### 🔐 Security & Authentication
- **PIN Login** with 3-attempt cooldown — wrong PIN 3× triggers a **30-second lock**
- **5 incorrect attempts** triggers a **permanent account lockout** (persisted locally)
- **App Inactivity Lock** — background for >300 seconds auto-presents a non-dismissible `PinLockScreen`

### 🎨 UI & Theming
- **Dynamic Dark / Light Mode** — toggle from Profile, persisted via `SharedPreferences`
- **Premium Bezier Spline Chart** — volatile daily spending with vertical touch-tracker & dynamic tooltips
- **Budget Progress Tracker** — visual spending category breakdown

### 💬 Chat & Communication
- **Live Customer Service Chat** — real-time simulator with message statuses (`sending` → `sent` → `read`)
- **Auto-reply** after 1.5s simulated network delay

### 📷 QR Payment
- **Real Camera Feed** via `mobile_scanner` with custom corner-bracket viewfinder overlay
- **"Simulasi Scan QR"** fallback bottom sheet with dummy merchants for emulator testing
- **QR Code Generation** for personal payment ID

### 💰 Finance Dashboard
- Volatile line chart with touch-pointer interaction
- Spending summary by category
- Balance deduction / refund with real-time state updates
- Full transaction history logging

---

## 📸 Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/69e2527d-1001-44fe-b343-ca49d117f675" width="180" alt="PIN Payment" />
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/e237fe19-3809-4701-9bf9-69388d955087" width="180" alt="QR Scanner" />
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/590575a0-0b77-4515-b449-122532e1e0c7" width="180" alt="My QR Code" />
</p>
<p align="center">
  <sub>🔐 PIN Payment &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 📷 QR Scanner &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 🔳 My QR Code</sub>
</p>

<br/>

<p align="center">
  <img src="https://github.com/user-attachments/assets/06b95b4e-ca36-4b35-8073-fe4727338e2c" width="180" alt="Finance Dashboard" />
</p>
<p align="center">
  <sub>📊 Finance Dashboard — Laporan Keuangan & Live Chart</sub>
</p>

---

## 🏗️ Architecture

This project strictly follows **Clean Architecture** for scalability, testability, and clear separation of concerns.

```
lib/
├── app/
│   ├── themes/             # Light & Dark ThemeData configuration
│   └── routes/             # Dynamic named routes & screen generators
├── core/
│   ├── constants/          # AppConstants & DummyData
│   ├── errors/             # Custom exceptions (e.g. InsufficientBalanceException)
│   ├── extensions/         # Capitalize, masking, and formatting helpers
│   ├── providers/          # State Notifiers (Auth, Balance, Transaction, Chat, Theme)
│   ├── services/           # Mock authentication and transaction logic
│   └── utils/              # Currency formatters & validators
├── data/
│   └── models/             # UserModel, TransactionModel, ChatMessage, etc.
└── presentation/
    ├── screens/            # UI layers (Splash, Onboarding, Home, Finance, etc.)
    └── widgets/            # Reusable components (Buttons, Cards, TextFields)
```

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.41.7 (stable channel)
- **Language**: Dart 3.11.5
- **DevTools**: 2.54.2
- **Engine**: `7a53c052bc4b472cf780b199087e1368e4a9aa8c`

---

## 📦 Libraries Used

| Library | Version | Purpose |
|:---|:---:|:---|
| [`provider`](https://pub.dev/packages/provider) | ^6.1.2 | Reactive state management |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | ^2.2.3 | Local persistence (dark mode, lockout state) |
| [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) | ^5.0.0 | Real camera QR code scanning |
| [`qr_flutter`](https://pub.dev/packages/qr_flutter) | ^4.1.0 | QR code generation for payment ID |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | ^6.2.1 | Plus Jakarta Sans typography |
| [`smooth_page_indicator`](https://pub.dev/packages/smooth_page_indicator) | ^1.1.0 | Onboarding page dot indicators |
| [`intl`](https://pub.dev/packages/intl) | ^0.19.0 | Currency & date formatting (IDR) |

---

## 🔒 Security Mechanism

| Trigger | Action |
|:---|:---|
| 3 wrong PIN attempts | 30-second cooldown lock |
| 5 wrong PIN attempts | Permanent lockout (saved locally) |
| App in background > 300s | Auto-present non-dismissible `PinLockScreen` |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>= 3.41.0`
- [Dart SDK](https://dart.dev/get-dart) `>= 3.11.0`
- Android Studio / Xcode / Chrome (for web)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/WagyuuA5/ovo_clone.git
cd ovo_clone

# 2. Install dependencies
flutter pub get

# 3. Run on emulator / device
flutter run

# 4. Run on Chrome (web)
flutter run -d chrome
```

---

## 📄 License

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

---

## 👨‍💻 Author

<table>
  <tr>
    <td align="center">
      <strong>Wahyu Ravi Anggoro</strong><br/>
      <code>@WagyuuA5</code><br/>
      Student at SMK Telkom Malang — 2026<br/>
      <a href="https://github.com/WagyuuA5">github.com/WagyuuA5</a>
    </td>
  </tr>
</table>

---

## 🙏 Acknowledgements

- [Flutter Team](https://flutter.dev) — for the amazing cross-platform framework
- [OVO](https://ovo.id) — original design inspiration
- [SMK Telkom Malang](https://smktelkom-mlg.sch.id) — for the learning environment and project support
- All open-source library authors listed above

---

<p align="center">
  Made with ❤️ and 💜 by <strong>Wahyu Ravi Anggoro</strong> · SMK Telkom Malang · 2026
</p>
