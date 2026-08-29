import 'package:flutter/foundation.dart';

enum AlertMode { immediate, countdown }

enum ShakeSensitivity { low, medium, high }

@immutable
class AppSettings {
  final String userId;
  final AlertMode alertMode;
  final ShakeSensitivity shakeSensitivity;
  final int countdownSeconds;
  final bool locationSharingEnabled;
  final String emergencyMessage;
  final bool protectionActive;
  final bool hasCompletedOnboarding;

  const AppSettings({
    required this.userId,
    this.alertMode = AlertMode.immediate,
    this.shakeSensitivity = ShakeSensitivity.medium,
    this.countdownSeconds = 10,
    this.locationSharingEnabled = true,
    this.emergencyMessage = '🚨 EMERGENCY ALERT!\n\nI may be in danger and need help.\n\nThis alert was sent from SafeShake.\n\nMy location: [LOCATION LINK]',
    this.protectionActive = true,
    this.hasCompletedOnboarding = false,
  });

  AppSettings copyWith({
    String? userId,
    AlertMode? alertMode,
    ShakeSensitivity? shakeSensitivity,
    int? countdownSeconds,
    bool? locationSharingEnabled,
    String? emergencyMessage,
    bool? protectionActive,
    bool? hasCompletedOnboarding,
  }) {
    return AppSettings(
      userId: userId ?? this.userId,
      alertMode: alertMode ?? this.alertMode,
      shakeSensitivity: shakeSensitivity ?? this.shakeSensitivity,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      emergencyMessage: emergencyMessage ?? this.emergencyMessage,
      protectionActive: protectionActive ?? this.protectionActive,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toMap() => {
    'alertMode': alertMode.name,
    'shakeSensitivity': shakeSensitivity.name,
    'countdownSeconds': countdownSeconds,
    'locationSharingEnabled': locationSharingEnabled,
    'emergencyMessage': emergencyMessage,
    'protectionActive': protectionActive,
    'hasCompletedOnboarding': hasCompletedOnboarding,
  };

  factory AppSettings.fromMap(String userId, Map<String, dynamic> map) {
    return AppSettings(
      userId: userId,
      alertMode: AlertMode.values.firstWhere(
        (e) => e.name == map['alertMode'],
        orElse: () => AlertMode.immediate,
      ),
      shakeSensitivity: ShakeSensitivity.values.firstWhere(
        (e) => e.name == map['shakeSensitivity'],
        orElse: () => ShakeSensitivity.medium,
      ),
      countdownSeconds: map['countdownSeconds'] ?? 10,
      locationSharingEnabled: map['locationSharingEnabled'] ?? true,
      emergencyMessage: map['emergencyMessage'] ?? '🚨 EMERGENCY ALERT!\n\nI may be in danger and need help.\n\nThis alert was sent from SafeShake.\n\nMy location: [LOCATION LINK]',
      protectionActive: map['protectionActive'] ?? true,
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
    );
  }
}
