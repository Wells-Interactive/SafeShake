import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../constants/app_constants.dart';
import '../models/app_settings.dart';

class ShakeService {
  static const int _cooldownMs = AppConstants.shakeCooldownMs;
  static const int _debounceMs = AppConstants.shakeDebounceMs;
  static const double _mediumThreshold = AppConstants.defaultShakeThreshold;

  final Function() onShakeDetected;
  final void Function(Object error)? onError;
  final ShakeSensitivity sensitivity;
  final Stream<UserAccelerometerEvent> Function() _userAccelerationStream;
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  Timer? _cooldownTimer;
  bool _isActive = false;
  DateTime? _lastTrigger;
  DateTime? _lastEvent;
  bool _cooldown = false;

  ShakeService({
    required this.onShakeDetected,
    this.onError,
    this.sensitivity = ShakeSensitivity.medium,
    Stream<UserAccelerometerEvent> Function()? userAccelerationStream,
  }) : _userAccelerationStream =
            userAccelerationStream ?? userAccelerometerEventStream;

  bool get isActive => _isActive;
  double get currentThreshold => switch (sensitivity) {
        ShakeSensitivity.low => 4.0,
        ShakeSensitivity.medium => _mediumThreshold,
        ShakeSensitivity.high => 1.5,
      };

  void start() {
    if (_isActive) return;
    _isActive = true;
    _subscription = _userAccelerationStream().listen(
      _onAccelerometerEvent,
      onError: (Object error) => onError?.call(error),
    );
  }

  void stop() {
    _isActive = false;
    _subscription?.cancel();
    _subscription = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _cooldown = false;
  }

  void _onAccelerometerEvent(UserAccelerometerEvent event) {
    if (!_isActive || _cooldown) return;

    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    final now = DateTime.now();

    if (_lastEvent != null &&
        now.difference(_lastEvent!).inMilliseconds < _debounceMs) {
      return;
    }

    if (magnitude > currentThreshold) {
      if (_lastTrigger != null &&
          now.difference(_lastTrigger!).inMilliseconds < _cooldownMs) {
        return;
      }
      _lastTrigger = now;
      _cooldown = true;
      _lastEvent = now;

      _cooldownTimer = Timer(const Duration(milliseconds: _cooldownMs), () {
        _cooldown = false;
        _cooldownTimer = null;
      });

      onShakeDetected();
    }

    _lastEvent = now;
  }

  void dispose() {
    stop();
  }
}
