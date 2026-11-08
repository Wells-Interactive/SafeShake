# SafeShake

> **Safety in the Shake of Your Hand.**

**SafeShake** is a personal safety and emergency alert application developed by Brainyte for **Wells Interactive**.

Formerly known as **SOSAlerts**, SafeShake is designed to provide a fast, discreet, and accessible way for users to alert trusted contacts when they feel unsafe or require urgent assistance.

## 🚨 Seeking Collaborations

SafeShake is currently seeking strategic partnerships, and collaboration opportunities to support its development and launch.

We believe personal safety technology should be simple, accessible, and available when people need it most.

---

# 🧪 Testing

Get the latest Android version of SafeShake.

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.wellsint.brainyte.safeshake">
    <img src="https://www.gstatic.com/android/market_images/web/play_prism_hlock_v2_1x.png" alt="Download SafeShake">
  </a>
</p>
 **Android:** Download the latest version from Google Play Store, You must have been added to the list to see it Or wait till release date.
NOTE: This Version is only for testing, So all message sending might not work you are free to report bugs.
---

# 📱 Supported Platforms

* Android
* iOS

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

## 📩 Emergency Alerts

SafeShake opens the device SMS composer with the emergency message for each
trusted contact. If the SMS composer cannot be opened, it tries that contact's
saved email address in the device mail composer. Add an email address to a
contact to enable this fallback.

The user must tap Send in the SMS or email app. Mobile platforms do not report
whether a composed message was actually sent or delivered, so SafeShake can
only fall back when it cannot open the SMS composer—not when delivery fails.

## 👥 Emergency Contact Management

Users can:

* Add emergency contacts
* Edit existing contacts
* Remove contacts
* Select contacts for emergency alerts
* Up to 5 contacts maximum

## 📍 Optional Location Sharing

When enabled and permitted, SafeShake can include the user's current location with an emergency alert.

## ⏰ Morning Reminder

SafeShake schedules a local notification for 8:00 AM in the device's local time
to remind users to open the app. Notifications must be allowed in device
settings. The reminder does not force the app to open or keep shake monitoring
running while the app is closed.

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

New users are directed to the sign-in screen first and can create an account
there. Google Sign-In uses Firebase Authentication credentials. After enabling
the Google provider, download fresh platform configuration from Firebase:
Android needs a matching OAuth client for the application ID and signing
fingerprint; iOS needs the Google client ID and its reversed-client-ID URL
scheme in `Info.plist`. The current iOS Firebase plist does not include those
Google OAuth entries.

---



# 🔒 Security Notes

* Never commit signing keys, keystores, or API secrets
* Firebase security rules enforce user-owned data
* Profile pictures are optional and user-owned
* Location sharing is permission-aware

---

# ⚠️ Platform Limitations

* SMS and email alerts open device composers; users must send the messages. SafeShake cannot verify delivery.
* Push notifications are prepared for future use but v1 does not implement emergency push delivery.
* Background shake monitoring is subject to modern Android background restrictions.
* SafeShake cannot force itself to open every morning or remain in the foreground continuously. The local reminder prompts users to open it; shake monitoring currently runs only while the app is open.

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
