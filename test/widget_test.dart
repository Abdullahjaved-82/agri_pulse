import 'package:flutter_test/flutter_test.dart';

import 'package:agri_pulse/main.dart';

void main() {
  testWidgets('Splash screen renders and navigates to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('AgriPulse'), findsOneWidget);
    expect(find.text('Smart Agricultural Market Intelligence'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Login to AgriPulse'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}
