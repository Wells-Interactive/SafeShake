import 'package:flutter/material.dart';

class TestModeScreen extends StatelessWidget {
  const TestModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Mode')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.science, size: 72),
              const SizedBox(height: 16),
              Text('TEST MODE', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'You can test the SafeShake workflow here. No real emergency SMS or alert is sent.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {},
                child: const Text('Run Test Alert'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
