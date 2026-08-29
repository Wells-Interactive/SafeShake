import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/models/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            subtitle: Text(settings.protectionActive ? 'Shake detection is on' : 'Shake detection is paused'),
            value: settings.protectionActive,
            onChanged: (value) => settingsProvider.setProtectionActive(value),
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
            subtitle: Text(settings.alertMode == AlertMode.immediate ? 'Immediate' : 'Countdown (${settings.countdownSeconds}s)'),
            onTap: () => _showAlertModeDialog(context, settingsProvider),
          ),
          ListTile(
            leading: Icon(settings.locationSharingEnabled ? Icons.location_on : Icons.location_off_outlined),
            title: const Text('Location Sharing'),
            subtitle: Text(settings.locationSharingEnabled ? 'Enabled' : 'Disabled'),
            onTap: () => settingsProvider.setLocationSharing(!settings.locationSharingEnabled),
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
            subtitle: Text(context.read<AuthProvider>().user?.email ?? 'Not signed in'),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About SafeShake'),
            subtitle: const Text('Safety in the Shake of Your Hand'),
            onTap: () {},
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
    final countdownController = TextEditingController(text: provider.countdownSeconds.toString());
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
                        decoration: const InputDecoration(labelText: 'Seconds (3-30)'),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
