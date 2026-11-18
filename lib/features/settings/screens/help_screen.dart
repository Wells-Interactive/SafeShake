import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HelpSection(
            title: 'Set up emergency alerts',
            icon: Icons.checklist,
            children: [
              Text(
                '1. Sign in and add trusted contacts from the Contacts tab. '
                'Enter an email address and a phone number, then enable that contact for alerts.',
              ),
              Text(
                '2. Turn on Protection and keep its notification allowed. '
                'On Android, the ongoing SafeShake notification should remain visible.',
              ),
              Text(
                '3. To include your location, enable Location Sharing, allow '
                'location access, and keep the device location service on.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Emergency contacts',
            icon: Icons.people_outline,
            children: [
              Text(
                '• You can add up to 5 emergency contacts.',
              ),
              Text(
                '• Each contact must have a unique phone number, duplicates are not allowed.',
              ),
              Text(
                '• You will be notified when a contact is added or removed.',
              ),
              Text(
                '• At least one enabled contact with a valid email address is required for email alerts. '
                'Phone numbers are used for SMS fallback when there is no internet.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Trigger an alert',
            icon: Icons.warning_outlined,
            children: [
              Text(
                '• Shake your phone strongly while Protection is active. SafeShake requires two shakes within a short time window to avoid false alarms.',
              ),
              Text(
                '• Use the Manual SOS button on the Home screen when a shake gesture is not possible.',
              ),
              Text(
                '• A cancel window appears before an alert is sent, tap Cancel on the protection notification if the shake was accidental.',
              ),
              Text(
                '• After an alert is sent (email/SMS), you may be prompted to share the emergency message via WhatsApp.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Keep protection available',
            icon: Icons.shield_outlined,
            children: [
              Text(
                '• On Android, do not force-stop SafeShake. Some devices may limit background activity; check battery settings if monitoring stops.',
              ),
              Text(
                '• Disable battery optimization for SafeShake (Settings → Apps → SafeShake → Battery → Unrestricted) so the system does not put the background service to sleep.',
              ),
              Text(
                '• On iPhone, shake monitoring works only while SafeShake is open. The morning reminder does not open the app or keep it running in the background.',
              ),
              Text(
                '• Allow internet access. Email alerts depend on the SafeShake email service being configured and available.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Location in alerts',
            icon: Icons.location_on,
            children: [
              Text(
                '• SafeShake fetches your exact latitude and longitude and adds a Google Maps link to the emergency message.',
              ),
              Text(
                '• If a fresh GPS fix times out, SafeShake sends your last known cached location instead of waiting.',
              ),
              Text(
                '• Location sharing can be turned off in Settings — the alert will then be sent without a location link.',
              ),
            ],
          ),
          _HelpSection(
            title: 'What Test Mode checks',
            icon: Icons.science_outlined,
            children: [
              Text(
                '• The Test tab runs a local simulation only. It sends no email and does not verify contact addresses, Gmail configuration, or inbox delivery.',
              ),
              Text(
                '• If an alert fails, check that you are signed in, have internet access, Protection is active, and at least one enabled contact has a valid email address or phone number. On Android, also check the protection notification for an error.',
              ),
              Text(
                '• If these checks do not help, contact the SafeShake app operator about the email service configuration.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Updates',
            icon: Icons.system_update,
            children: [
              Text(
                '• SafeShake checks for critical updates after the app opens.',
              ),
              Text(
                '• If an update is required, a non-dismissible dialog will direct you to the Google Play Store.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Important delivery limits',
            icon: Icons.info_outline,
            children: [
              Text(
                '• Though 100% guaranteed delivery is not possible, Brainyte Nigeria is working to make SafeShake a guaranteed safety option. A successful response means the provider accepted the send request; it does not guarantee delivery.',
              ),
              Text(
                '• Messages can be delayed, filtered, or rejected later, and SafeShake cannot know whether a recipient has read an email or SMS.',
              ),
              Text(
                '• Cellular voice and SMS signals often reach further than mobile data, but SMS delivery still depends on carrier coverage.',
              ),
              Text(
                '• SafeShake is an additional option for contacting people you trust, not an emergency service and not continuously monitored. Do not rely on it as your only way to get help.',
              ),
              Text(
                '• If you are in immediate danger, contact your local emergency services or use another available way to reach help.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _HelpSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
