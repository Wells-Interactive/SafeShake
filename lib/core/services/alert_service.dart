import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_settings.dart';
import '../models/emergency_contact.dart';
import 'location_service.dart';

typedef AlertComposerLauncher = Future<bool> Function(Uri uri);

class AlertService {
  final LocationService _locationService = LocationService();
  final AlertComposerLauncher _launchComposer;

  AlertService({AlertComposerLauncher? launchComposer})
      : _launchComposer = launchComposer ??
            ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication));

  bool _isAlerting = false;
  Timer? _countdownTimer;
  Completer<void>? _countdownCompleter;
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
    try {
      if (settings.alertMode == AlertMode.countdown && !testMode) {
        await _runCountdown(settings, enabledContacts);
      } else {
        await _executeAlert(
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

  Future<void> _runCountdown(
      AppSettings settings, List<EmergencyContact> contacts) async {
    _remainingSeconds = settings.countdownSeconds;
    final completer = Completer<void>();
    _countdownCompleter = completer;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds = _remainingSeconds! - 1;
      if (_remainingSeconds! <= 0) {
        timer.cancel();
        _countdownTimer = null;
        _countdownCompleter = null;
        () async {
          try {
            await _executeAlert(
                testMode: false, settings: settings, contacts: contacts);
            completer.complete();
          } catch (error, stackTrace) {
            completer.completeError(error, stackTrace);
          } finally {
            _remainingSeconds = null;
          }
        }();
      }
    });
    await completer.future;
  }

  Future<void> _executeAlert({
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
      return;
    }

    await _openAlertComposers(contacts, message);
  }

  Future<void> _openAlertComposers(
    List<EmergencyContact> contacts,
    String message,
  ) async {
    final failures = <String>[];
    for (final contact in contacts) {
      final smsFailure = await _openComposer(smsComposerUri(contact, message));
      if (smsFailure == null) continue;

      if (contact.email.trim().isEmpty) {
        failures.add(
          '${contact.name}: SMS composer failed ($smsFailure); no email address is saved.',
        );
        continue;
      }

      final emailFailure =
          await _openComposer(emailComposerUri(contact, message));
      if (emailFailure != null) {
        failures.add(
          '${contact.name}: SMS composer failed ($smsFailure); email composer failed ($emailFailure).',
        );
      }
    }

    if (failures.isNotEmpty) {
      throw AlertDeliveryException(failures.join(' '));
    }
  }

  Future<String?> _openComposer(Uri uri) async {
    try {
      return await _launchComposer(uri)
          ? null
          : 'No application can open this message.';
    } on PlatformException catch (error) {
      return error.message ?? error.code;
    }
  }

  static Uri smsComposerUri(EmergencyContact contact, String message) {
    return Uri(
      scheme: 'sms',
      path: contact.phoneNumber,
      queryParameters: {'body': message},
    );
  }

  static Uri emailComposerUri(EmergencyContact contact, String message) {
    return Uri(
      scheme: 'mailto',
      path: contact.email,
      queryParameters: {
        'subject': 'SafeShake emergency alert',
        'body': message,
      },
    );
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
  String toString() => message;
}
