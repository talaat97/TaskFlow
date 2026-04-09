# TaskFlow — Flutter Task Management App

A production-quality Flutter task management app built with **Clean Architecture**, **Riverpod**, **Dio**, and a premium dark UI. 

Designed to demonstrate solid architectural patterns, secure authentication, and a responsive, polished user interface without relying on default cookie-cutter Material Design.

![TaskFlow App Demo](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![State Management](https://img.shields.io/badge/State_Management-Riverpod-blueviolet)
![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-brightgreen)

https://github.com/user-attachments/assets/290d832f-d4d0-423c-8fd7-d0202df7cf85



## ✨ Features

- **Secure Authentication:** JWT-based login with automatic token injection via Dio interceptors, and secure storage on the device.
- **Auto-Login:** Splash screen intelligently routes users based on previously saved valid sessions.
- **Full CRUD Operations:** Create, read, update, and delete tasks instantly.
- **Client-Side Filtering:** Quickly search tasks or filter by Status (To Do, In Progress, Done) and Priority (Low, Medium, High).
- **Premium UI:** Custom dark theme `#0A0A12`, violet accents, glassmorphism cards, shimmer loading effects, and micro-animations (Slide/Fade/Hero transitions).

---

## 🏗️ Architecture Stack

This project follows **Feature-based Clean Architecture** dividing the app into distinct layers for maintainability and scalability:

- **Presentation:** Riverpod (`AsyncNotifier`, `StateNotifier`), GoRouter (for guarded navigation)
- **Domain:** Pure Dart entities and abstract repositories, completely independent of external packages
- **Data:** Models, remote data sources (via Dio), and repository implementations
- **Core:** Shared utilities, API constants, custom UI components, and the `flutter_secure_storage` implementation

---

## 🚀 Setup & Installation

This project relies on a custom local `json-server-auth` mock API. You must run the API server *before* running the Flutter app.

### Step 1: Start the Mock API

The mock API is powered by Node.js. It is included directly in this repository in the `mock-api` folder.

> **Important:** Keep the API running in a separate terminal while you test the Flutter app.

```bash
# Navigate to the mock API folder inside the project
cd mock-api/

# 1. Install dependencies (First time only)
npm install

# 2. Setup the database with hashed passwords (First time only)
npm run setup

# 3. Start the server (Run this EVERY time)
npm start
```
The server will start on `http://localhost:3000`. 
**Test credentials:** `test@example.com` / `password123`

---

### Step 2: Configure Android Network Connection

Since iOS Simulator uses `localhost` directly, no configuration is needed for iOS. 

For **Android Emulators & Real Devices**, Android blocks cleartext HTTP (which the local mock API uses) by default. This project has been pre-configured with a network security config (`network_security_config.xml`) and `usesCleartextTraffic="true"` to bypass this locally.

**Running on a Real Android Device via USB?**
The best way to bypass Windows/Mac firewall restrictions is using an `adb reverse` tunnel. This maps your phone's localhost to your PC's localhost.

1. Ensure your device is connected via USB and USB debugging is on.
2. Run this command in your terminal (Run this EVERY time you re-plug your phone):
   ```bash
   adb reverse tcp:3000 tcp:3000
   ```
3. In `lib/core/constants/api_constants.dart`, ensure `kUseAdbReverse` is set to `true`:
   ```dart
   const bool kUseAdbReverse = true;
   ```

*(If you are running via Wi-Fi only, set `kUseAdbReverse` to `false` and change `kDevMachineIp` to your PC's local LAN IP).*

---

### Step 3: Run the Flutter App

Once the API represents your local endpoint and `adb reverse` is active (if Android physical device):

```bash
flutter pub get
flutter run
```

---

## 🧪 Testing

The project includes widget tests demonstrating proper form validation (e.g., verifying empty fields, malformed emails, and password lengths).

```bash
# Run widget tests for the authentication form
flutter test test/features/auth/login_form_test.dart
```

---

## 📂 Project Structure

```text
lib/
├── app/            # GoRouter configuration, AppTheme, and MaterialApp root
├── core/           
│   ├── constants/  # API endpoints, secure storage keys
│   ├── network/    # Singleton DioClient and AuthInterceptor
│   ├── storage/    # SecureStorage wrapper
│   └── widgets/    # Shared UI: Shimmer loaders, custom badges, snackbars
└── features/
    ├── auth/       # Authentication Feature Flow
    │   ├── data/   
    │   ├── domain/ 
    │   └── presentation/ 
    │
    └── tasks/      # Task Management Feature Flow
        ├── data/   
        ├── domain/ 
        └── presentation/ 
```
## 📦 Key Dependencies

- [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod): Reactive State Management
- [`go_router`](https://pub.dev/packages/go_router): Declarative routing with Auth Guards
- [`dio`](https://pub.dev/packages/dio): Robust HTTP client
- [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage): Keystore/Keychain integration for JWT handling
- [`google_fonts`](https://pub.dev/packages/google_fonts): Typography (Inter)
- [`shimmer`](https://pub.dev/packages/shimmer): Loading state skeletons
