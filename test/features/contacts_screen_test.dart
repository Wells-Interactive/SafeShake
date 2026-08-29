import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:safeshake/features/emergency_contacts/screens/contacts_screen.dart';
import 'package:safeshake/shared/providers/contacts_provider.dart';
import 'package:safeshake/core/constants/app_constants.dart';

void main() {
  testWidgets('ContactsScreen shows empty state when no contacts', (tester) async {
    final provider = ContactsProvider('test-uid');
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(value: provider, child: const ContactsScreen()),
      ),
    );
    expect(find.text('No contacts yet'), findsOneWidget);
    expect(find.text('0 of ${AppConstants.maxContacts} configured'), findsNothing);
  });
}
