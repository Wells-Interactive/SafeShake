import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.vibration),
            title: Text('Shake Sensitivity'),
            subtitle: Text('Medium'),
          ),
          ListTile(
            leading: Icon(Icons.flash_on),
            title: Text('Alert Mode'),
            subtitle: Text('Immediate'),
          ),
          ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('Location Sharing'),
            subtitle: Text('Optional'),
          ),
          ListTile(
            leading: Icon(Icons.message_outlined),
            title: Text('Emergency Message'),
            subtitle: Text('Customize your alert message'),
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Accidental Activation Protection'),
            subtitle: Text('Cooldown and activation safeguards'),
          ),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Account'),
            subtitle: Text('Profile and authentication'),
          ),
        ],
      ),
    );
  }
}
