import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/emergency_contact.dart';
import 'location_service.dart';

class AlertService {
  final LocationService _locationService = LocationService();

  bool _isAlerting = false;
  Timer? _countdownTimer;
  int? _remainingSeconds;

  bool get isAlerting => _isAlerting;
  int? get remainingSeconds => _remainingSeconds;

  Future<void> triggerAlert({
    required bool testMode,
    required AppSettings settings,
    required List<EmergencyContact> contacts,
  }) async {
    if (_isAlerting) return;
    if (contacts.isEmpty) return;

    final enabledContacts = contacts.where((c) => c.enabled).toList();
    if (enabledContacts.isEmpty) return;

    _isAlerting = true;

    if (settings.alertMode == AlertMode.countdown && !testMode) {
      await _runCountdown(settings, enabledContacts);
    } else {
      await _executeAlert(testMode: testMode, settings: settings, contacts: enabledContacts);
    }

    _isAlerting = false;
  }

  Future<void> cancelAlert() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingSeconds = null;
    _isAlerting = false;
  }

  Stream<int>? get countdownStream {
    if (_remainingSeconds == null) return null;
    return Stream.periodic(const Duration(seconds: 1), (count) => _remainingSeconds! - count - 1)
        .take(_remainingSeconds!)
        .map((s) => _remainingSeconds! - s);
  }

  Future<void> _runCountdown(AppSettings settings, List<EmergencyContact> contacts) async {
    _remainingSeconds = settings.countdownSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds = _remainingSeconds! - 1;
      if (_remainingSeconds! <= 0) {
        timer.cancel();
        _countdownTimer = null;
        _executeAlert(testMode: false, settings: settings, contacts: contacts);
      }
    });
  }

  Future<void> _executeAlert({
    required bool testMode,
    required AppSettings settings,
    required List<EmergencyContact> contacts,
  }) async {
    String message = settings.emergencyMessage;
    if (settings.locationSharingEnabled) {
      final locationLink = await _locationService.getEmergencyLocationLink();
      if (locationLink != null) {
        message = message.replaceAll('[LOCATION LINK]', locationLink);
      } else {
        message = message.replaceAll('[LOCATION LINK]', 'Location unavailable');
      }
    } else {
      message = message.replaceAll('[LOCATION LINK]', 'Location sharing disabled');
    }

    if (kDebugMode) {
      if (testMode) {
        print('[TEST MODE] Would send alert to ${contacts.length} contacts:');
      } else {
        print('[ALERT] Sending alert to ${contacts.length} contacts:');
      }
      for (final contact in contacts) {
        print('  - ${contact.name}: ${contact.phoneNumber}');
      }
      print('Message: $message');
    }

    await Future.delayed(const Duration(milliseconds: 500));
  }
}
