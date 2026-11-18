import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/app_settings.dart';
import '../models/emergency_contact.dart';
import 'location_service.dart';

typedef EmergencyEmailSender = Future<void> Function(String message);

class AlertService {
  final LocationService _locationService = LocationService();
  final EmergencyEmailSender _sendEmail;

  AlertService({EmergencyEmailSender? sendEmail})
      : _sendEmail = sendEmail ?? _sendEmergencyEmail;

  bool _isAlerting = false;
  Timer? _countdownTimer;
  Completer<void>? _countdownCompleter;
  int? _remainingSeconds;

  bool get isAlerting => _isAlerting;
  int? get remainingSeconds => _remainingSeconds;

  Future<String?> triggerAlert({
    required bool testMode,
    required AppSettings settings,
    required List<EmergencyContact> contacts,
  }) async {
    if (_isAlerting) return null;
    if (contacts.isEmpty) return null;

    final enabledContacts = contacts.where((c) => c.enabled).toList();
    if (enabledContacts.isEmpty) return null;

    _isAlerting = true;
    try {
      if (settings.alertMode == AlertMode.countdown && !testMode) {
        return await _runCountdown(settings, enabledContacts);
      } else {
        return await _executeAlert(
            testMode: testMode, settings: settings, contacts: enabledContacts);
      }
    } finally {
      _isAlerting = false;
    }
  }

  Future<void> cancelAlert() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingSeconds = null;
    final completer = _countdownCompleter;
    _countdownCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _isAlerting = false;
  }

  Stream<int>? get countdownStream {
    if (_remainingSeconds == null) return null;
    return Stream.periodic(const Duration(seconds: 1),
            (count) => _remainingSeconds! - count - 1)
        .take(_remainingSeconds!)
        .map((s) => _remainingSeconds! - s);
  }

  Future<String?> _runCountdown(
      AppSettings settings, List<EmergencyContact> contacts) async {
    _remainingSeconds = settings.countdownSeconds;
    final completer = Completer<String?>();
    _countdownCompleter = completer;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds = _remainingSeconds! - 1;
      if (_remainingSeconds! <= 0) {
        timer.cancel();
        _countdownTimer = null;
        _countdownCompleter = null;
        () async {
          try {
            final msg = await _executeAlert(
                testMode: false, settings: settings, contacts: contacts);
            completer.complete(msg);
          } catch (error, stackTrace) {
            completer.completeError(error, stackTrace);
          } finally {
            _remainingSeconds = null;
          }
        }();
      }
    });
    return completer.future;
  }

  Future<String?> _executeAlert({
    required bool testMode,
    required AppSettings settings,
    required List<EmergencyContact> contacts,
  }) async {
    final locationLink = settings.locationSharingEnabled && !testMode
        ? await _locationService.getEmergencyLocationLink()
        : null;
    final message = composeEmergencyMessage(
      settings: settings,
      locationLink: locationLink,
    );

    if (testMode) {
      if (kDebugMode) {
        debugPrint(
            '[TEST MODE] Prepared an alert for ${contacts.length} contacts.');
      }
      return message;
    }

    if (!contacts.any((contact) => contact.email.trim().isNotEmpty)) {
      throw const AlertDeliveryException(
        'No enabled emergency contact has an email address saved.',
      );
    }

    await _sendEmail(message);
    return message;
  }

  static Future<void> _sendEmergencyEmail(String message) async {
    final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable('sendEmergencyAlert');
    try {
      await callable.call({'message': message});
    } on FirebaseFunctionsException catch (error) {
      throw AlertDeliveryException(
        error.message ?? 'Gmail API could not send the emergency email (${error.code}).',
      );
    }
  }

  static String composeEmergencyMessage({
    required AppSettings settings,
    String? locationLink,
  }) {
    final location = !settings.locationSharingEnabled
        ? 'Location sharing disabled'
        : locationLink ?? 'Location unavailable';
    if (settings.emergencyMessage.contains('[LOCATION LINK]')) {
      return settings.emergencyMessage.replaceAll('[LOCATION LINK]', location);
    }
    if (settings.locationSharingEnabled) {
      return '${settings.emergencyMessage}\n\nMy location: $location';
    }
    return settings.emergencyMessage;
  }
}

class AlertDeliveryException implements Exception {
  final String message;

  const AlertDeliveryException(this.message);

  @override
  String toString() => 'Alert delivery failed: $message';
}
