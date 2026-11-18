import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/providers/contacts_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/shake_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/foreground_monitor_service.dart';
import '../../../../core/services/update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _updatingProtection = false;
  bool _updateChecked = false;
  ShakeProvider? _shakeProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shakeProvider = context.read<ShakeProvider>();
      _shakeProvider?.addListener(_onShakeProviderChanged);
      _initializeProviders();
      _checkForUpdate();
    });
  }

  @override
  void dispose() {
    _shakeProvider?.removeListener(_onShakeProviderChanged);
    super.dispose();
  }

  void _onShakeProviderChanged() {
    final sp = _shakeProvider;
    if (sp == null || !mounted) return;
    if (sp.lastAlertMessage != null && sp.lastError == null) {
      final msg = sp.lastAlertMessage!;
      sp.clearLastAlertMessage();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showWhatsAppShareDialog(msg);
      });
    }
  }

  Future<void> _checkForUpdate() async {
    if (_updateChecked) return;
    _updateChecked = true;
    final updateService = UpdateService();
    final minVersion = await updateService.getMinRequiredVersion();
    if (minVersion == null || !mounted) return;
    final current = await updateService.getCurrentVersion();
    if (!updateService.isUpdateRequired(current, minVersion) || !mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('A Better SafeShake Awaits!'),
          content: const Text(
            'We\'ve made SafeShake even better for you. Update now to enjoy the latest improvements and stay protected.',
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                final uri = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.wellsint.brainyte.safeshake',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
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
      if (contactsProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not verify emergency contacts: ${contactsProvider.errorMessage}',
            ),
          ),
        );
        return;
      }

      if (!contactsProvider.hasEnabledEmailContact) {
        await settingsProvider.setProtectionActive(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Protection was paused. Add and enable a contact with a valid email address first.',
              ),
            ),
          );
        }
        return;
      }

      try {
        if (Platform.isAndroid) {
          if (!await ForegroundMonitorService.requestNotificationPermission()) {
            throw StateError(
                'Notification permission is required for protection.');
          }
          await ForegroundMonitorService.start(settingsProvider.settings);
        } else {
          shakeProvider.startListening(
            settingsProvider.settings,
            contactsProvider.contacts,
          );
        }
      } on PlatformException catch (error) {
        await settingsProvider.setProtectionActive(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Could not start protection: ${error.message}')),
          );
        }
      } on StateError catch (error) {
        await settingsProvider.setProtectionActive(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message.toString())),
          );
        }
      }
    }
  }

  Future<void> _setProtectionActive(bool active) async {
    if (_updatingProtection) return;
    final settingsProvider = context.read<SettingsProvider>();
    final contactsProvider = context.read<ContactsProvider>();
    final shakeProvider = context.read<ShakeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _updatingProtection = true);
    try {
      if (active && contactsProvider.isLoading) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Wait for emergency contacts to finish loading.')),
        );
        return;
      }
      if (active && contactsProvider.errorMessage != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Could not verify emergency contacts: ${contactsProvider.errorMessage}',
            ),
          ),
        );
        return;
      }
      if (active && !contactsProvider.hasEnabledEmailContact) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Add and enable a contact with a valid email address before turning protection on.',
            ),
          ),
        );
        return;
      }

      if (active && Platform.isAndroid) {
        final confirmed = await _confirmAndroidProtection();
        if (!confirmed || !mounted) return;
        if (!await ForegroundMonitorService.requestNotificationPermission()) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                  'Allow notifications to keep protection visibly active.'),
            ),
          );
          return;
        }
      }

      final success = await settingsProvider.setProtectionActive(active);
      if (!mounted) return;
      if (!success) {
        if (active && settingsProvider.settings.protectionActive) {
          await settingsProvider.setProtectionActive(false);
        }
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

      if (!Platform.isAndroid && active) {
        shakeProvider.startListening(
          settingsProvider.settings,
          contactsProvider.contacts,
        );
      } else if (!Platform.isAndroid) {
        shakeProvider.stopListening();
      }
    } finally {
      if (mounted) setState(() => _updatingProtection = false);
    }
  }

  Future<void> _triggerManualSos() async {
    final settingsProvider = context.read<SettingsProvider>();
    final contactsProvider = context.read<ContactsProvider>();
    final shakeProvider = context.read<ShakeProvider>();

    if (contactsProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not verify emergency contacts: ${contactsProvider.errorMessage}',
          ),
        ),
      );
      return;
    }
    if (!contactsProvider.hasEnabledEmailContact) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add and enable a contact with a valid email address first.',
          ),
        ),
      );
      return;
    }

    await shakeProvider.handleShake(
      settingsProvider.settings,
      contactsProvider.contacts,
    );
  }

  Future<void> _showWhatsAppShareDialog(String message) async {
    final share = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share via WhatsApp'),
        content: const Text(
          'Would you like to share the emergency message on WhatsApp? This will open WhatsApp so you can choose a contact and send it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Share'),
          ),
        ],
      ),
    );
    if (share != true) return;
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    }
  }

  Future<bool> _confirmAndroidProtection() async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable background protection?'),
          content: const Text(
            'SafeShake will keep an ongoing notification while it monitors for shakes. '
            'A detected shake starts a cancel window before an email alert is sent. '
            'Android may still stop the service, and alerts are not guaranteed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enable'),
            ),
          ],
        ),
      ) ??
      false;

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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: protectionActive
                        ? AppColors.active.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                protectionActive
                                    ? Icons.shield
                                    : Icons.pause_circle_outline,
                                size: 40,
                                color: protectionActive
                                    ? AppColors.active
                                    : Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      protectionActive
                                          ? 'PROTECTION ACTIVE'
                                          : 'PROTECTION PAUSED',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: protectionActive
                                                ? AppColors.active
                                                : null,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      protectionActive
                                          ? 'Shake strongly to trigger alert.'
                                          : 'Shake detection paused.',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: protectionActive,
                                onChanged: _updatingProtection
                                    ? null
                                    : _setProtectionActive,
                              ),
                            ],
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
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.safety,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    onPressed: _updatingProtection ? null : _triggerManualSos,
                    icon: const Icon(Icons.error_outline, color: Colors.white),
                    label: const Text(
                      'MANUAL SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
