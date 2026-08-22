import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool protectionActive = true;

  @override
  Widget build(BuildContext context) {
    final active = protectionActive;
    return Scaffold(
      appBar: AppBar(title: const Text('SafeShake')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      active ? Icons.shield : Icons.pause_circle_outline,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      active ? 'PROTECTION ACTIVE' : 'PROTECTION PAUSED',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(active
                        ? 'Shake your phone strongly to trigger your configured alert.'
                        : 'Shake detection is currently paused.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Protection'),
                      value: protectionActive,
                      onChanged: (value) => setState(() => protectionActive = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.people),
                title: Text('Emergency Contacts'),
                subtitle: Text('0 of 5 contacts configured'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.science),
              label: const Text('TEST SAFESHAKE'),
            ),
          ],
        ),
      ),
    );
  }
}
