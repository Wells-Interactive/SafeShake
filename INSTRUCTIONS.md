# SafeShake — Implementation Instructions

## Mission

You are the implementation agent for **SafeShake**. Take the repository from its starter state to a complete, buildable, testable Flutter application. Do not stop at placeholders: implement features, fix build issues, add useful tests, and keep documentation current.

**Product:** SafeShake  
**Tagline:** Safety in the Shake of Your Hand  
**Former name:** SOSAlerts  
**Organization:** Wells Interactive / Brainyte

---

# 1. Non-Negotiable Identity

```text
App name: SafeShake
Dart package: safeshake
Android namespace: com.wellsint.brainyte.safeshake
Android applicationId: com.wellsint.brainyte.safeshake
```

Do not change the Android namespace or application ID.

Platforms:

- Android
- iOS

Theme:

```text
ThemeMode.system
```

The app must support device light and dark mode.

---

# 2. Version 1 Requirements

Implement:

1. User registration and authentication
2. User profile management
3. Emergency contact management
4. Maximum of 5 emergency contacts
5. Strong shake detection
6. Protection Active / Paused
7. Immediate and countdown alert modes
8. Custom emergency messages
9. Optional location sharing
10. Current location with last-known-location fallback
11. Safe Test Mode
12. Accidental activation protection
13. Firebase integration
14. Android and iOS support
15. Responsive, polished UI
16. Loading, empty, and error states
17. Permission handling
18. Documentation and tests

Do not represent unfinished functionality as completed.

---

# 3. Confirmed Product Decisions

These decisions are already approved.

## Authentication

Support:

- Email and password
- Google Sign-In
- Phone number authentication

Registration:

Required:
- Full name
- Email
- Password
- Confirm password

Optional:
- Phone number
- Profile picture

## Emergency Contacts

Maximum:

```text
5
```

Users can:

- Add
- Edit
- Delete
- Enable/disable contacts for alerts

## Shake Detection

Default sensitivity:

```text
Medium
```

Default trigger:

```text
One strong shake
```

The implementation must include:

- Sensor threshold validation
- Debounce logic
- Cooldown after activation
- Prevention of duplicate simultaneous alerts
- Proper disposal of sensor subscriptions
- No triggering when protection is paused

Do not trigger on every accelerometer spike.

## Alert Modes

Users can choose:

### Immediate
Trigger the configured emergency workflow immediately.

### Countdown
Show a countdown with a visible:

```text
CANCEL
```

Default:

```text
Immediate
```

## Location

Use:

1. Current location
2. Last known location fallback
3. Continue gracefully if neither is available

Location sharing is optional and permission-aware.

## Test Mode

Test Mode must:

- Exercise the real workflow where safe
- Respect shake and countdown settings
- Clearly display TEST MODE
- Simulate the result
- Never send a real SMS or emergency alert

This is a hard safety requirement.

## Emergency History

Do not implement emergency history in v1.

## Protection State

Support:

```text
PROTECTION ACTIVE
```

and:

```text
PROTECTION PAUSED
```

When paused, shake detection must not activate an emergency workflow.

## Accidental Activation Protection

Implement practical safeguards including:

- Threshold validation
- Debounce
- Cooldown
- Concurrent activation guard
- Countdown cancellation when applicable
- Protection state checks

---

# 4. Navigation

After onboarding, use bottom navigation:

```text
Home
Contacts
Test
Settings
```

The Home screen is the main safety dashboard.

---

# 5. Home Screen

Include:

- SafeShake branding
- Protection status
- Clear visual difference between active and paused
- Explanation of current behavior
- Emergency contact summary
- Access to Test Mode
- Protection toggle
- Incomplete setup state

Example direction:

```text
SafeShake

PROTECTION ACTIVE

Shake your phone strongly to trigger
your configured emergency alert.

Emergency Contacts
3 of 5 configured

[ TEST SAFESHAKE ]

Protection: ON
```

Never show “active” if permissions, setup, or implementation state prevents actual protection.

---

# 6. Onboarding

Recommended flow:

```text
Splash
↓
Welcome
↓
Create Account / Sign In
↓
Basic Profile
↓
Emergency Contacts
↓
Emergency Message
↓
Permissions
↓
Location Preference
↓
Shake Configuration
↓
Alert Mode
↓
Setup Complete
↓
Home
```

Optional information must not be unnecessarily required.

Explain sensitive permissions in context.

---

# 7. Firebase

Use:

- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Firebase Crashlytics

After FlutterFire configuration, use the generated:

```text
firebase_options.dart
```

Do not invent Firebase credentials or hardcode secrets.

## Authentication

Implement:

- Email registration
- Email sign-in
- Password reset
- Google Sign-In
- Phone authentication

All flows need validation, loading states, and understandable errors.

---

# 8. Firestore Model and Security

Use user-owned data.

Recommended:

```text
users/{uid}
users/{uid}/emergencyContacts/{contactId}
```

Settings may be stored on the user document or under a dedicated settings document. Pick one approach and use it consistently.

Provide Firestore security rules enforcing:

```text
request.auth.uid
```

Users must not be able to read or modify another user's:

- Profile
- Settings
- Emergency contacts

Document how to deploy the rules.

---

# 9. Firebase Storage

Profile pictures are optional.

If implemented:

- Use user-owned paths
- Restrict access to the owner
- Validate type/size where practical
- Provide Storage security guidance/rules

---

# 10. Messaging and Crashlytics

Prepare Firebase Cloud Messaging correctly for future notifications.

Version 1 does not need to pretend that push notifications are emergency SMS.

Initialize Crashlytics appropriately and avoid silently swallowing unexpected errors.

---

# 11. Emergency Contacts

Each contact should include at minimum:

```text
id
name
phoneNumber
enabled
```

The feature must include real CRUD and Firestore persistence.

UI requirements:

- Empty state
- Configured count, such as `3 of 5`
- Add contact
- Edit contact
- Delete confirmation where appropriate
- Prevent adding a sixth contact

---

# 12. Emergency Message

Use a sensible default:

```text
🚨 EMERGENCY ALERT!

I may be in danger and need help.

This alert was sent from SafeShake.

My location: [LOCATION LINK]
```

Allow customization.

If location is disabled or unavailable, do not leave a broken placeholder.

---

# 13. Alert Architecture

Separate:

```text
Detection
```

from:

```text
Alert orchestration
```

from:

```text
Delivery
```

Use clean services or equivalent abstractions.

Important platform rule:

Android and iOS do not provide identical support for automated/background SMS.

Therefore:

- Respect current Android and iOS capabilities and policies
- Do not fake delivery success
- Do not assume one SMS implementation works identically on both platforms
- Surface limitations honestly
- Keep delivery mechanisms replaceable

Future delivery mechanisms may include:

- Platform messaging flows
- Backend delivery
- Push notifications
- Trusted-contact services

---

# 14. Shake Detection

Implement with a reliable sensor package.

Requirements:

- Medium sensitivity by default
- One strong shake by default
- Configurable sensitivity if exposed in Settings
- No activation while paused
- Debounce repeated sensor events
- Cooldown after activation
- No simultaneous workflows
- Clean subscription disposal
- Reasonable battery behavior

Use named constants and document threshold logic.

---

# 15. Location

Implement a location service flow:

```text
Check preference
↓
Check service availability
↓
Check permission
↓
Request permission when appropriate
↓
Try current location
↓
Fallback to last known location
↓
Generate location representation
```

Handle:

- Denied permission
- Permanently denied permission
- Disabled location services
- Timeout
- No known location

Request location only in context.

---

# 16. Permissions

Create a central permission service.

Possible permissions depend on implementation:

- Location
- Notifications
- Platform messaging capabilities

Rules:

- Explain why
- Request in context
- Handle denial
- Do not spam permission prompts
- Provide a route to system settings when permanently denied

---

# 17. Settings

Implement real, persistent settings for:

- Shake sensitivity
- Alert mode
- Countdown duration
- Location sharing
- Emergency message
- Accidental activation safeguards
- Profile/account
- Sign out

Do not leave Settings as static list tiles.

---

# 18. UI and Accessibility

SafeShake should feel:

- Calm
- Trustworthy
- Modern
- Safety-focused
- Slightly futuristic

Use Material 3 unless there is a documented reason not to.

Do not scatter hardcoded colors through widgets. Use centralized theme and semantic colors.

Accessibility:

- Good contrast
- Readable text
- Meaningful button labels
- Do not rely on icons alone for critical information
- Clearly distinguish active and paused states

---

# 19. Logo and Branding

Use the approved SafeShake visual direction when assets are available:

- Location-pin/shield-inspired mark
- Deep navy/violet interior
- Cyan/blue illuminated edge
- Soft blue background
- Layered depth
- Soft shadows
- Slightly futuristic
- Stylized central S

Place assets appropriately under:

```text
assets/images/
assets/icons/
```

Do not distort branding.

---

# 20. Architecture

Maintain a feature-oriented structure:

```text
lib/
├── app/
│   ├── app.dart
│   ├── routes/
│   └── theme/
├── core/
│   ├── constants/
│   ├── models/
│   ├── permissions/
│   ├── services/
│   └── utils/
├── features/
│   ├── authentication/
│   ├── emergency_alert/
│   ├── emergency_contacts/
│   ├── home/
│   ├── location/
│   ├── onboarding/
│   ├── settings/
│   ├── shake_detection/
│   ├── splash/
│   └── test_mode/
└── shared/
    └── widgets/
```

The starter uses Provider. Continue with Provider unless there is a compelling reason to make a consistent project-wide change.

Do not mix unrelated state-management patterns without justification.

Keep business logic out of large UI widgets.

---

# 21. Error and Loading States

Every important asynchronous action should expose an appropriate state:

- Initial
- Loading
- Success
- Empty
- Error

Examples:

- Login failure
- Registration failure
- Firestore failure
- Permission denial
- Location failure
- Profile upload failure
- Contact save failure

Do not show raw stack traces to users.

---

# 22. Native Configuration

## Android

Ensure exactly:

```text
namespace = com.wellsint.brainyte.safeshake
applicationId = com.wellsint.brainyte.safeshake
```

Only declare permissions actually required.

Review modern Android background restrictions before implementing continuous shake monitoring.

## iOS

Configure:

- Required usage descriptions
- Firebase integration
- Sign-In requirements
- Location permission descriptions
- Notification permissions

Do not assume Android background behavior exists on iOS.

---

# 23. Security

Never commit:

- Signing keys
- Keystores
- Private API secrets
- Environment secrets
- Credentials

Keep `.gitignore` current.

Firebase configuration does not replace Firebase security rules.

---

# 24. Tests

Add meaningful tests.

Prioritize unit tests for:

- Contact limit enforcement
- Alert mode behavior
- Shake debounce/cooldown logic
- Location fallback logic
- Emergency message construction

Add widget tests for:

- Protection active/paused state
- Contacts empty state
- Five-contact limit
- Test Mode safety messaging
- Authentication validation

Do not create meaningless tests purely to inflate coverage.

---

# 25. README

Keep the README current and professional.

Include:

- Product overview
- Tagline
- Features
- Supported platforms
- Architecture
- Firebase setup
- Local setup
- Running the app
- Testing
- Security notes
- Platform limitations
- Project status
- Funding and partnership information
- Wells Interactive / Brainyte attribution

Do not claim the application is publicly available unless it is.

---

# 26. Definition of Done

Do not mark implementation complete until applicable items are satisfied.

## Project Health

- [ ] `flutter pub get` succeeds
- [ ] Dart analysis is clean or warnings are documented
- [ ] Android build is attempted and errors resolved
- [ ] iOS project configuration is valid
- [ ] Tests run where supported

## Identity

- [ ] App displays as SafeShake
- [ ] Namespace is exactly `com.wellsint.brainyte.safeshake`

## Authentication

- [ ] Email registration
- [ ] Email sign-in
- [ ] Password reset
- [ ] Google Sign-In
- [ ] Phone authentication or clearly isolated external setup requirement

## Firebase

- [ ] Correct Firebase initialization
- [ ] User-owned Firestore data
- [ ] Firestore security rules
- [ ] Storage security guidance if Storage is used
- [ ] Crashlytics prepared
- [ ] Messaging prepared

## Safety Features

- [ ] Active/Paused works
- [ ] Shake detector respects state
- [ ] Medium sensitivity default
- [ ] One strong shake default
- [ ] Debounce/cooldown works
- [ ] Immediate workflow works
- [ ] Countdown cancellation works
- [ ] Test Mode never sends a real alert
- [ ] Location fallback works
- [ ] Five-contact limit enforced

## UX

- [ ] Light mode
- [ ] Dark mode
- [ ] Loading states
- [ ] Error states
- [ ] Empty states
- [ ] Accessibility basics
- [ ] No fake success states

## Code Quality

- [ ] Completed features do not retain abandoned placeholders
- [ ] No unnecessary duplication
- [ ] UI and business logic are reasonably separated
- [ ] Sensitive values are not committed
- [ ] README updated

---

# 27. Required Work Order

Work in approximately this order:

1. Inspect the repository.
2. Preserve project identity and namespace.
3. Repair Flutter structure if necessary.
4. Ensure the starter builds.
5. Configure Firebase architecture.
6. Implement authentication.
7. Implement profile persistence.
8. Build onboarding.
9. Implement contacts and Firestore persistence.
10. Implement persistent settings.
11. Implement location and permissions.
12. Implement shake detection with safeguards.
13. Implement alert orchestration.
14. Implement immediate and countdown modes.
15. Implement Test Mode.
16. Connect the Home dashboard to real state.
17. Prepare Crashlytics and messaging.
18. Add tests.
19. Review Android and iOS configuration.
20. Run formatting, analysis, tests, and builds.
21. Update documentation.

---

# 28. Final Report

When finished, report:

1. What was implemented
2. Main files/areas changed
3. Firebase setup still required from the repository owner
4. Platform-specific limitations
5. Validation commands and results
6. Remaining blockers, if any

Do not claim completion for a feature that is only a UI placeholder.

If completion requires Firebase Console access, credentials, signing keys, physical-device testing, or another external dependency, implement everything possible in the repository and clearly identify the remaining manual step.

---

# Guiding Principle

SafeShake is a safety-oriented application.

Prioritize:

- Reliability
- Clarity
- Privacy
- Permission transparency
- Prevention of accidental activation
- Maintainability

When choosing between clever and predictable:

> **Choose the predictable, maintainable implementation.**
