# SafeShake

> **Safety in the Shake of Your Hand.**

**SafeShake** is a personal safety and emergency alert application developed by Brainyte for **Wells Interactive**.

Formerly known as **SOSAlerts**, SafeShake is designed to provide a fast, discreet, and accessible way for users to alert trusted contacts when they feel unsafe or require urgent assistance.

## 🚨 Seeking Partnerships

SafeShake is currently seeking strategic partnerships, and collaboration opportunities to support its development and launch.

We believe personal safety technology should be simple, accessible, and available when people need it most.

---

# ⚠️ The Problem

Every day, people find themselves in situations where they feel unsafe but may be unable to make a phone call, type a message, or visibly ask for help.

Traditional emergency methods can sometimes be difficult or impossible to use in situations involving:

* Personal threats
* Medical emergencies
* Isolation
* Unsafe environments
* Situations where discretion is essential

There is a need for a fast, simple, and discreet way to alert trusted people during an emergency.

---

# 💡 The Solution

## SafeShake

SafeShake provides a quick and discreet way to send an emergency alert to trusted contacts.

The app is designed around a simple concept:

> **Shake your phone to trigger an emergency alert.**

When activated, SafeShake can send a predefined emergency message to selected emergency contacts and optionally include the user's location.

State management uses **Provider**. Business logic is separated into services and providers.

---

# ✨ Key Features

## 📳 Shake Detection

Highly responsive shake detection designed to provide a quick and accessible method of activating an emergency alert.

## 📩 Emergency SMS Alerts

Send a customizable emergency message to designated trusted contacts.

## 👥 Emergency Contact Management

Users can:

* Add emergency contacts
* Edit existing contacts
* Remove contacts
* Select contacts for emergency alerts
* Up to 5 contacts maximum

## 📍 Optional Location Sharing

When enabled and permitted, SafeShake can include the user's current location with an emergency alert.

## ⚙️ Customization

Users can personalize:

* Emergency messages
* Emergency contacts
* Shake sensitivity
* Alert settings
* Location sharing preferences

## 🧪 Test Mode

A dedicated test mode allows users to test SafeShake without sending a real emergency SMS.

---

# 🔐 Authentication

SafeShake supports:

* Email and password registration/sign-in
* Google Sign-In
* Phone number authentication
* Password reset

---

# 🔥 Firebase Setup

SafeShake uses Firebase for authentication, Firestore, Storage, Messaging, and Crashlytics.

### Prerequisites

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android and iOS apps to the project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Run `flutterfire configure` to generate `lib/firebase_options.dart`

### Firestore Security Rules

Deploy the following rules to Firestore:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /contacts/{contactId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

# 🚀 Local Setup

### Prerequisites

* Flutter SDK >= 3.4.0
* Android Studio / Xcode
* Firebase project configured

### Steps

```bash
# Clone the repository
git clone <repository-url>
cd SafeShake

# Install dependencies
flutter pub get

# Generate Firebase options (requires FlutterFire CLI)
flutterfire configure

# Run the app
flutter run
```

---

# 🧪 Testing

```bash
flutter test
```

Tests cover:
* Contact model serialization
* Settings model roundtrip
* Input validation
* Alert service behavior
* Contacts empty state widget

---

# 📱 Supported Platforms

* Android
* iOS

---

# 🔒 Security Notes

* Never commit signing keys, keystores, or API secrets
* Firebase security rules enforce user-owned data
* Profile pictures are optional and user-owned
* Location sharing is permission-aware

---

# ⚠️ Platform Limitations

* **Android and iOS do not provide identical support for automated/background SMS.** SafeShake respects current platform capabilities and does not fake delivery success.
* Push notifications are prepared for future use but v1 does not implement emergency push delivery.
* Background shake monitoring is subject to modern Android background restrictions.

---

# 📲 Availability

SafeShake is currently in development.

---

# 🏢 Developed By

## Brainyte

Building practical technology solutions for people, businesses, and communities.

🌐 [Wells Interactive](http://www.wellsint.site)

---

# 👋 Contact

**Mr. Wells**

For enquiries, collaboration opportunities, or partnerships:

[Contact Mr. Wells](https://linktr.ee/mrwellslife)

---

<p align="center">

**SafeShake**

### *Safety in the Shake of Your Hand.*

Built by Brainyte for **Wells Interactive**

</p>
