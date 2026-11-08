import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/providers/contacts_provider.dart';
import '../../../../core/models/app_settings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < AppConstants.onboardingSteps.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.setOnboardingComplete(true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: AppConstants.onboardingSteps.length,
                itemBuilder: (context, index) {
                  return _buildPage(context, index);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), child: const Text('Back'))
                  else
                    const SizedBox(width: 80),
                  Expanded(
                    child: FilledButton(
                      onPressed: _nextPage,
                      child: Text(_currentPage == AppConstants.onboardingSteps.length - 1 ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, int index) {
    final step = AppConstants.onboardingSteps[index];
    final settingsProvider = context.watch<SettingsProvider>();
    final contactsProvider = context.watch<ContactsProvider>();

    switch (step) {
      case 'welcome':
        return _WelcomeStep();
      case 'createAccount':
        return _CreateAccountStep();
      case 'basicProfile':
        return _BasicProfileStep(settingsProvider: settingsProvider);
      case 'emergencyContacts':
        return _EmergencyContactsStep(contactsProvider: contactsProvider);
      case 'emergencyMessage':
        return _EmergencyMessageStep(settingsProvider: settingsProvider);
      case 'permissions':
        return _PermissionsStep();
      case 'locationPreference':
        return _LocationPreferenceStep(settingsProvider: settingsProvider);
      case 'shakeConfiguration':
        return _ShakeConfigurationStep(settingsProvider: settingsProvider);
      case 'alertMode':
        return _AlertModeStep(settingsProvider: settingsProvider);
      case 'setupComplete':
        return _SetupCompleteStep();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.health_and_safety_rounded, size: 96, color: AppColors.safety),
          const SizedBox(height: 24),
          Text('Welcome to SafeShake', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text('Safety in the Shake of Your Hand', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text('Let\'s set up your emergency alert profile. This will only take a few minutes.', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _CreateAccountStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('Please create your account first using the login screen.', textAlign: TextAlign.center)),
    );
  }
}

class _BasicProfileStep extends StatelessWidget {
  final SettingsProvider settingsProvider;
  const _BasicProfileStep({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: context.read<AuthProvider>().user?.displayName ?? '');
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Basic Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outlined)),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            enabled: false,
            controller: TextEditingController(text: context.read<AuthProvider>().user?.email ?? ''),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactsStep extends StatelessWidget {
  final ContactsProvider contactsProvider;
  const _EmergencyContactsStep({required this.contactsProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Emergency Contacts', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('${contactsProvider.contacts.length} of ${AppConstants.maxContacts} configured'),
          const SizedBox(height: 24),
          const Text('You can add contacts later from the Contacts tab.'),
        ],
      ),
    );
  }
}

class _EmergencyMessageStep extends StatelessWidget {
  final SettingsProvider settingsProvider;
  const _EmergencyMessageStep({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: settingsProvider.emergencyMessage);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Emergency Message', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Your emergency message', alignLabelWithHint: true),
          ),
        ],
      ),
    );
  }
}

class _PermissionsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('SafeShake needs location and notification permissions to function effectively.', textAlign: TextAlign.center)),
    );
  }
}

class _LocationPreferenceStep extends StatelessWidget {
  final SettingsProvider settingsProvider;
  const _LocationPreferenceStep({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Location Sharing', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Share location in alerts'),
            subtitle: const Text('Your location will be included in emergency alerts'),
            value: settingsProvider.locationSharingEnabled,
            onChanged: (value) => settingsProvider.setLocationSharing(value),
          ),
        ],
      ),
    );
  }
}

class _ShakeConfigurationStep extends StatelessWidget {
  final SettingsProvider settingsProvider;
  const _ShakeConfigurationStep({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Shake Sensitivity', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          SegmentedButton<ShakeSensitivity>(
            segments: const [
              ButtonSegment(value: ShakeSensitivity.low, label: Text('Low'), icon: Icon(Icons.touch_app)),
              ButtonSegment(value: ShakeSensitivity.medium, label: Text('Medium'), icon: Icon(Icons.touch_app)),
              ButtonSegment(value: ShakeSensitivity.high, label: Text('High'), icon: Icon(Icons.touch_app)),
            ],
            selected: {settingsProvider.shakeSensitivity},
            onSelectionChanged: (Set<ShakeSensitivity> newSelection) {
              settingsProvider.setShakeSensitivity(newSelection.first);
            },
          ),
        ],
      ),
    );
  }
}

class _AlertModeStep extends StatelessWidget {
  final SettingsProvider settingsProvider;
  const _AlertModeStep({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Alert Mode', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          SegmentedButton<AlertMode>(
            segments: const [
              ButtonSegment(value: AlertMode.immediate, label: Text('Immediate'), icon: Icon(Icons.flash_on)),
              ButtonSegment(value: AlertMode.countdown, label: Text('Countdown'), icon: Icon(Icons.timer)),
            ],
            selected: {settingsProvider.alertMode},
            onSelectionChanged: (Set<AlertMode> newSelection) {
              settingsProvider.setAlertMode(newSelection.first);
            },
          ),
        ],
      ),
    );
  }
}

class _SetupCompleteStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 96, color: AppColors.active),
          SizedBox(height: 24),
          Text('Setup Complete', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          SizedBox(height: 16),
          Text('You\'re all set! SafeShake is ready for emergencies.', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
