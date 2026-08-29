import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SafeShake app builds', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('SafeShake'))));
    expect(find.text('SafeShake'), findsOneWidget);
  });
}
