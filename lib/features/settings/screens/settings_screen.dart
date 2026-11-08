import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/contacts_provider.dart';
import '../../../../shared/providers/shake_provider.dart';
import '../../../../core/models/app_settings.dart';
import '../../../../core/services/location_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _updatingProtection = false;
  bool _updatingLocation = false;

  Future<void> _setProtectionActive(bool active) async {
    setState(() => _updatingProtection = true);
    final settingsProvider = context.read<SettingsProvider>();
    try {
      final success = await settingsProvider.setProtectionActive(active);
      if (!mounted) return;
      if (!success) {
        _showMessage(
          settingsProvider.errorMessage ??
              'Could not update protection settings.',
        );
        return;
      }

      final shakeProvider = context.read<ShakeProvider>();
      if (active) {
        shakeProvider.startListening(
          settingsProvider.settings,
          context.read<ContactsProvider>().contacts,
        );
      } else {
        shakeProvider.stopListening();
      }
    } finally {
      if (mounted) setState(() => _updatingProtection = false);
    }
  }

  Future<void> _setLocationSharing(bool enabled) async {
    setState(() => _updatingLocation = true);
    final settingsProvider = context.read<SettingsProvider>();
    try {
      if (enabled) {
        final locationService = LocationService();
        if (!await locationService.requestPermission()) {
          if (mounted) {
            _showMessage(
                'Allow location access to share your location in alerts.');
          }
          return;
        }
        if (!await locationService.isServiceEnabled()) {
          if (mounted) {
            _showMessage(
                'Turn on device location services to share your location.');
          }
          return;
        }
      }

      final success = await settingsProvider.setLocationSharing(enabled);
      if (!mounted || success) return;
      _showMessage(
        settingsProvider.errorMessage ?? 'Could not update location settings.',
      );
    } finally {
      if (mounted) setState(() => _updatingLocation = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About SafeShake'),
        content: const Text(
          'SafeShake is a simple, reliable safety companion designed to help you quickly alert trusted contacts when you need assistance',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Protection Active'),
            subtitle: Text(settings.protectionActive
                ? 'Shake detection is on'
                : 'Shake detection is paused'),
            value: settings.protectionActive,
            onChanged: _updatingProtection ? null : _setProtectionActive,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.vibration),
            title: const Text('Shake Sensitivity'),
            subtitle: Text(_sensitivityLabel(settings.shakeSensitivity)),
            onTap: () => _showSensitivityDialog(context, settingsProvider),
          ),
          ListTile(
            leading: const Icon(Icons.flash_on),
            title: const Text('Alert Mode'),
            subtitle: Text(settings.alertMode == AlertMode.immediate
                ? 'Immediate'
                : 'Countdown (${settings.countdownSeconds}s)'),
            onTap: () => _showAlertModeDialog(context, settingsProvider),
          ),
          ListTile(
            leading: Icon(settings.locationSharingEnabled
                ? Icons.location_on
                : Icons.location_off_outlined),
            title: const Text('Location Sharing'),
            subtitle:
                Text(settings.locationSharingEnabled ? 'Enabled' : 'Disabled'),
            trailing: _updatingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _updatingLocation
                ? null
                : () => _setLocationSharing(!settings.locationSharingEnabled),
          ),
          ListTile(
            leading: const Icon(Icons.message_outlined),
            title: const Text('Emergency Message'),
            subtitle: const Text('Customize your alert message'),
            onTap: () => _showMessageDialog(context, settingsProvider),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Account'),
            subtitle: Text(
                context.read<AuthProvider>().user?.email ?? 'Not signed in'),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About SafeShake'),
            subtitle: const Text('Safety in the Shake of Your Hand'),
            onTap: _showAbout,
          ),
        ],
      ),
    );
  }

  String _sensitivityLabel(ShakeSensitivity sensitivity) {
    switch (sensitivity) {
      case ShakeSensitivity.low:
        return 'Low';
      case ShakeSensitivity.medium:
        return 'Medium';
      case ShakeSensitivity.high:
        return 'High';
    }
  }

  void _showSensitivityDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shake Sensitivity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ShakeSensitivity.values.map((sensitivity) {
            return RadioListTile<ShakeSensitivity>(
              title: Text(_sensitivityLabel(sensitivity)),
              value: sensitivity,
              groupValue: provider.shakeSensitivity,
              onChanged: (value) {
                if (value != null) {
                  provider.setShakeSensitivity(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAlertModeDialog(BuildContext context, SettingsProvider provider) {
    final countdownController =
        TextEditingController(text: provider.countdownSeconds.toString());
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Alert Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AlertMode>(
                title: const Text('Immediate'),
                value: AlertMode.immediate,
                groupValue: provider.alertMode,
                onChanged: (value) {
                  if (value != null) {
                    provider.setAlertMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<AlertMode>(
                title: const Text('Countdown'),
                subtitle: provider.alertMode == AlertMode.countdown
                    ? TextField(
                        controller: countdownController,
                        decoration:
                            const InputDecoration(labelText: 'Seconds (3-30)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final seconds = int.tryParse(value);
                          if (seconds != null) {
                            provider.setCountdownSeconds(seconds);
                          }
                        },
                      )
                    : null,
                value: AlertMode.countdown,
                groupValue: provider.alertMode,
                onChanged: (value) {
                  if (value != null) {
                    provider.setAlertMode(value);
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageDialog(BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(text: provider.emergencyMessage);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Message'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(alignLabelWithHint: true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              provider.setEmergencyMessage(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
