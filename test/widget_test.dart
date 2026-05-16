import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:agri_pulse/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Login to AgriPulse'), findsOneWidget);
  });
}
