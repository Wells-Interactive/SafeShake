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

## 📳 Shake Detection (False-Alarm Filtered)

On Android, enabling Protection starts a native sensor foreground service with an ongoing notification. SafeShake requires **two shakes within a short time window** before triggering, which prevents false alarms from accidental movement. A detected shake displays a cancel action before an emergency alert is sent.

iOS shake detection remains active only while the app is open.

## 🚨 Manual SOS Button

A large, always-accessible "MANUAL SOS" button appears on the Home screen alongside shake detection. Use it when a shake gesture is not possible due to physical distress or a dropped phone.

## 👥 Emergency Contact Management

Users can:

* Add emergency contacts
* Edit existing contacts
* Remove contacts
* Select contacts for emergency alerts
* Up to 5 contacts maximum

Duplicate phone numbers are not allowed (numbers are normalized to prevent duplicates). Users receive notifications when contacts are added or removed.

## 📍 Optional Location Sharing

When enabled and permitted, SafeShake fetches the user's exact latitude and longitude and formats them into a standard Google Maps URL included in the emergency message.

If a fresh GPS fix times out during an emergency, SafeShake immediately sends the last known cached location instead of waiting.

## 📧 Email Alerts with SMS Fallback

SafeShake sends emergency email alerts silently in the background via the Gmail API once OAuth 2.0 permissions are granted.

If there is no internet connection during an emergency, SafeShake automatically falls back to sending a direct cellular SMS via Android's `SmsManager` API to the saved contact phone numbers.

## 🔄 Force Update

When a new minimum required version is published, SafeShake displays a non-dismissible update dialog at launch, directing users to update from the Google Play Store.

## ⏰ Morning Reminder

SafeShake schedules a local notification for 8:00 AM in the device's local time to remind users to open the app.

## ⚙️ Customization

Users can personalize:

* Emergency messages
* Emergency contacts
* Shake sensitivity
* Alert settings
* Location sharing preferences

## 🧪 Test Mode

A dedicated test mode allows users to test SafeShake without sending a real emergency alert.

---

# 🔋 Battery Optimization

On Android, disable battery optimization for SafeShake during onboarding (Settings → Apps → SafeShake → Battery → Unrestricted) so the operating system does not put the background monitoring service to sleep. SafeShake runs a persistent Foreground Service with a visible notification so the system does not terminate the shake listener.

---

# 🔐 Authentication

SafeShake supports:

* Email and password registration/sign-in
* Google Sign-In
* Phone number authentication
* Password reset

New users are directed to the sign-in screen first and can create an account there. Google Sign-In uses Firebase Authentication credentials.

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

# ⚠️ Important Safety Notice

**100% guaranteed delivery is not possible.** SafeShake is purely an additional option for contacting people you trust. It is not an emergency service, is not continuously monitored, and cannot guarantee that an alert will be detected or delivered. Do not rely on it as your only way to get help. If you are in immediate danger, contact your local emergency services or use another available way to reach help.

---

<p align="center">

**SafeShake**

### *Safety in the Shake of Your Hand.*

Built by Brainyte for **Wells Interactive**

</p>
