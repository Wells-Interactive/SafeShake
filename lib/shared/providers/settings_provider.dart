import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/app_settings.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/shake_service.dart';

class SettingsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final String? _userId;

  AppSettings _settings = const AppSettings(userId: '');
  bool _isLoading = false;
  String? _errorMessage;
  ShakeService? _shakeService;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AlertMode get alertMode => _settings.alertMode;
  ShakeSensitivity get shakeSensitivity => _settings.shakeSensitivity;
  int get countdownSeconds => _settings.countdownSeconds;
  bool get locationSharingEnabled => _settings.locationSharingEnabled;
  String get emergencyMessage => _settings.emergencyMessage;
  bool get protectionActive => _settings.protectionActive;
  bool get hasCompletedOnboarding => _settings.hasCompletedOnboarding;

  SettingsProvider(this._userId);

  Future<void> loadSettings() async {
    if (_userId == null || _userId.isEmpty) return;
    _setLoading(true);
    _clearError();
    try {
      final doc = await _firebaseService.userSettingsDoc(_userId).get();
      if (doc.exists) {
        _settings = AppSettings.fromMap(_userId, doc.data()!);
      } else {
        _settings = AppSettings(userId: _userId);
        await _saveSettings(_settings);
      }
      notifyListeners();
    } on FirebaseException catch (e) {
      _setError('Failed to load settings: ${e.message}');
    } catch (e) {
      _setError('An unexpected error occurred.');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateSettings(AppSettings newSettings) async {
    if (_userId == null || _userId.isEmpty) return false;
    _setLoading(true);
    _clearError();
    try {
      await _saveSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _setError('Failed to save settings: ${e.message}');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setAlertMode(AlertMode mode) async {
    final newSettings = _settings.copyWith(alertMode: mode);
    await updateSettings(newSettings);
  }

  Future<void> setShakeSensitivity(ShakeSensitivity sensitivity) async {
    final newSettings = _settings.copyWith(shakeSensitivity: sensitivity);
    await updateSettings(newSettings);
  }

  Future<void> setCountdownSeconds(int seconds) async {
    final clamped = seconds.clamp(3, 30);
    final newSettings = _settings.copyWith(countdownSeconds: clamped);
    await updateSettings(newSettings);
  }

  Future<void> setLocationSharing(bool enabled) async {
    final newSettings = _settings.copyWith(locationSharingEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> setEmergencyMessage(String message) async {
    final newSettings = _settings.copyWith(emergencyMessage: message);
    await updateSettings(newSettings);
  }

  Future<void> setProtectionActive(bool active) async {
    final newSettings = _settings.copyWith(protectionActive: active);
    await updateSettings(newSettings);
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final newSettings = _settings.copyWith(hasCompletedOnboarding: complete);
    await updateSettings(newSettings);
  }

  Future<void> _saveSettings(AppSettings settings) async {
    if (_userId == null || _userId.isEmpty) return;
    await _firebaseService
        .userSettingsDoc(_userId)
        .set(settings.toMap(), SetOptions(merge: true));
  }

  void setShakeService(ShakeService service) {
    _shakeService?.dispose();
    _shakeService = service;
  }

  @override
  void dispose() {
    _shakeService?.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
