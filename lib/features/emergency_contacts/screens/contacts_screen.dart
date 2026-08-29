import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/contacts_provider.dart';
import '../../../../core/models/emergency_contact.dart';
import '../../../../app/theme/app_colors.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsProvider = context.watch<ContactsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      floatingActionButton: contactsProvider.canAddMore
          ? FloatingActionButton.extended(
              onPressed: () => _showAddContactDialog(context, contactsProvider),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Contact'),
            )
          : null,
      body: contactsProvider.isLoading && contactsProvider.contacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : contactsProvider.contacts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('No contacts yet', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text('Add up to 5 trusted emergency contacts who will be notified in an emergency.'),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contactsProvider.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contactsProvider.contacts[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?')),
                        title: Text(contact.name),
                        subtitle: Text(contact.phoneNumber),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(contact.enabled ? Icons.notifications_active : Icons.notifications_off),
                              onPressed: () => contactsProvider.updateContact(contact.copyWith(enabled: !contact.enabled)),
                              tooltip: contact.enabled ? 'Disable alerts' : 'Enable alerts',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditContactDialog(context, contactsProvider, contact),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.safety),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Contact'),
                                    content: Text('Remove ${contact.name} from emergency contacts?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirm == true && context.mounted) {
                                  await contactsProvider.deleteContact(contact.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showAddContactDialog(BuildContext context, ContactsProvider provider) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    bool enabled = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              SwitchListTile(
                title: const Text('Enable for alerts'),
                value: enabled,
                onChanged: (value) => setDialogState(() => enabled = value),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;
                final contact = EmergencyContact(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  enabled: enabled,
                );
                final success = await provider.addContact(contact);
                if (success && context.mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditContactDialog(BuildContext context, ContactsProvider provider, EmergencyContact contact) async {
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phoneNumber);
    bool enabled = contact.enabled;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              SwitchListTile(
                title: const Text('Enable for alerts'),
                value: enabled,
                onChanged: (value) => setDialogState(() => enabled = value),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;
                final updated = contact.copyWith(
                  name: nameController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  enabled: enabled,
                );
                final success = await provider.updateContact(updated);
                if (success && context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
