import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/providers/contacts_provider.dart';
import '../../../../core/services/alert_service.dart';
import '../../../../app/theme/app_colors.dart';

class TestModeScreen extends StatefulWidget {
  const TestModeScreen({super.key});

  @override
  State<TestModeScreen> createState() => _TestModeScreenState();
}

class _TestModeScreenState extends State<TestModeScreen> {
  bool _isRunning = false;
  String? _result;

  Future<void> _runTest() async {
    setState(() {
      _isRunning = true;
      _result = null;
    });

    final settingsProvider = context.read<SettingsProvider>();
    final contactsProvider = context.read<ContactsProvider>();
    final alertService = context.read<AlertService>();

    try {
      await alertService.triggerAlert(
        testMode: true,
        settings: settingsProvider.settings,
        contacts: contactsProvider.contacts,
      );
      setState(() => _result = 'Test completed successfully. No real alert was sent.');
    } catch (e) {
      setState(() => _result = 'Test failed: ${e.toString()}');
    } finally {
      setState(() => _isRunning = false);
    }
  }

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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.safety.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.safety.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.science, size: 72, color: AppColors.safety),
                    SizedBox(height: 16),
                    Text('TEST MODE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.safety)),
                    SizedBox(height: 8),
                    Text('No real emergency SMS or alert is sent.', textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_isRunning)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Running test alert...'),
                  ],
                )
              else
                FilledButton.icon(
                  onPressed: _runTest,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Test Alert'),
                ),
              if (_result != null) ...[
                const SizedBox(height: 16),
                Text(_result!, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
