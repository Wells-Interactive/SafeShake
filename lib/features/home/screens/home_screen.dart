import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/providers/contacts_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/shake_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeProviders());
  }

  Future<void> _initializeProviders() async {
    final authProvider = context.read<AuthProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final contactsProvider = context.read<ContactsProvider>();
    final shakeProvider = context.read<ShakeProvider>();

    if (authProvider.user == null) return;

    await settingsProvider.loadSettings();
    if (!mounted) return;
    await contactsProvider.loadContacts();
    if (!mounted) return;

    if (settingsProvider.settings.protectionActive) {
      shakeProvider.startListening(
        settingsProvider.settings,
        contactsProvider.contacts,
      );
    }
  }

  Future<void> _setProtectionActive(bool active) async {
    final settingsProvider = context.read<SettingsProvider>();
    final contactsProvider = context.read<ContactsProvider>();
    final shakeProvider = context.read<ShakeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await settingsProvider.setProtectionActive(active);
    if (!mounted) return;
    if (!success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            settingsProvider.errorMessage ??
                'Could not update protection settings.',
          ),
        ),
      );
      return;
    }

    if (active) {
      shakeProvider.startListening(
        settingsProvider.settings,
        contactsProvider.contacts,
      );
    } else {
      shakeProvider.stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final contactsProvider = context.watch<ContactsProvider>();
    final shakeProvider = context.watch<ShakeProvider>();

    final settings = settingsProvider.settings;
    final protectionActive = settings.protectionActive;
    final contactsCount = contactsProvider.contacts.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeShake'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final navigator = Navigator.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sign Out')),
                  ],
                ),
              );
              if (confirm != true || !mounted) return;
              await authProvider.signOut();
              if (!mounted) return;
              navigator.pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: authProvider.user == null
          ? const Center(child: Text('Please sign in to access SafeShake.'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: protectionActive
                        ? AppColors.active.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            protectionActive
                                ? Icons.shield
                                : Icons.pause_circle_outline,
                            size: 72,
                            color: protectionActive
                                ? AppColors.active
                                : Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            protectionActive
                                ? 'PROTECTION ACTIVE'
                                : 'PROTECTION PAUSED',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: protectionActive
                                      ? AppColors.active
                                      : null,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            protectionActive
                                ? 'Shake your phone strongly to trigger your configured alert.'
                                : 'Shake detection is currently paused.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Protection'),
                            value: protectionActive,
                            onChanged: (value) => _setProtectionActive(value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Emergency Contacts'),
                      subtitle: Text(
                          '$contactsCount of ${AppConstants.maxContacts} configured'),
                      trailing: contactsProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/test'),
                    icon: const Icon(Icons.science),
                    label: const Text('TEST SAFESHAKE'),
                  ),
                  if (shakeProvider.lastError != null) ...[
                    const SizedBox(height: 16),
                    Text(shakeProvider.lastError!,
                        style: const TextStyle(color: AppColors.safety),
                        textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
    );
  }
}
