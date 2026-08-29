import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../constants/app_constants.dart';

class ShakeService {
  static const int _cooldownMs = AppConstants.shakeCooldownMs;
  static const int _debounceMs = AppConstants.shakeDebounceMs;
  static const double _mediumThreshold = AppConstants.defaultShakeThreshold;

  final Function() onShakeDetected;
  StreamSubscription<AccelerometerEvent>? _subscription;
  bool _isActive = false;
  DateTime? _lastTrigger;
  DateTime? _lastEvent;
  bool _cooldown = false;

  ShakeService({required this.onShakeDetected});

  bool get isActive => _isActive;
  double get currentThreshold => _mediumThreshold;

  void start() {
    if (_isActive) return;
    _isActive = true;
    _subscription = accelerometerEvents.listen(_onAccelerometerEvent);
  }

  void stop() {
    _isActive = false;
    _subscription?.cancel();
    _subscription = null;
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (!_isActive || _cooldown) return;

    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    final now = DateTime.now();

    if (_lastEvent != null && now.difference(_lastEvent!).inMilliseconds < _debounceMs) {
      return;
    }

    if (magnitude > currentThreshold) {
      if (_lastTrigger != null && now.difference(_lastTrigger!).inMilliseconds < _cooldownMs) {
        return;
      }
      _lastTrigger = now;
      _cooldown = true;
      _lastEvent = now;

      Future.delayed(const Duration(milliseconds: _cooldownMs), () {
        _cooldown = false;
      });

      onShakeDetected();
    }

    _lastEvent = now;
  }

  void dispose() {
    stop();
  }
}
