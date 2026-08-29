import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/services/alert_service.dart';
import '../../core/services/shake_service.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/emergency_contact.dart';

class ShakeProvider extends ChangeNotifier {
  final AlertService _alertService;
  final Function(AppSettings)? onSettingsChanged;

  ShakeService? _shakeService;
  bool _isActive = false;
  bool _isProcessing = false;
  String? _lastError;

  ShakeProvider(this._alertService, {this.onSettingsChanged});

  bool get isActive => _isActive;
  bool get isProcessing => _isProcessing;
  String? get lastError => _lastError;

  void attachShakeService(ShakeService service) {
    _shakeService?.dispose();
    _shakeService = service;
  }

  void startListening(AppSettings settings, List<EmergencyContact> contacts) {
    if (_isActive) return;
    _isActive = true;
    _lastError = null;

    _shakeService = ShakeService(
      onShakeDetected: () => handleShake(settings, contacts),
    );
    _shakeService!.start();
    notifyListeners();
  }

  void stopListening() {
    _isActive = false;
    _shakeService?.dispose();
    _shakeService = null;
    notifyListeners();
  }

  Future<void> handleShake(AppSettings settings, List<EmergencyContact> contacts) async {
    if (_isProcessing) return;
    if (!settings.protectionActive) return;
    if (contacts.isEmpty) return;

    _isProcessing = true;
    _lastError = null;
    notifyListeners();

    try {
      await _alertService.triggerAlert(
        testMode: false,
        settings: settings,
        contacts: contacts,
      );
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _shakeService?.dispose();
    super.dispose();
  }
}
