class AppConstants {
  static const int maxContacts = 5;
  static const int shakeCooldownMs = 5000;
  static const int shakeDebounceMs = 800;
  static const double defaultShakeThreshold = 2.5;
  static const int defaultCountdownSeconds = 10;
  static const String defaultEmergencyMessage = '🚨 EMERGENCY ALERT!\n\nI may be in danger and need help.\n\nThis alert was sent from SafeShake.\n\nMy location: [LOCATION LINK]';
  static const String firebaseUsersCollection = 'users';
  static const String firebaseContactsSubcollection = 'emergencyContacts';
  static const String firebaseSettingsDocument = 'settings';

  static const List<String> onboardingSteps = [
    'welcome',
    'createAccount',
    'basicProfile',
    'emergencyContacts',
    'emergencyMessage',
    'permissions',
    'locationPreference',
    'shakeConfiguration',
    'alertMode',
    'setupComplete',
  ];
}
