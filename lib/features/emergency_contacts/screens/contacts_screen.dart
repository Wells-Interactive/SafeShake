import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add contact flow, enforcing a maximum of 5 contacts.
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Contact'),
      ),
      body: const Center(
        child: Text('Add up to 5 trusted emergency contacts.'),
      ),
    );
  }
}
