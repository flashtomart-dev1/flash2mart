import 'package:flutter_test/flutter_test.dart';
import 'package:flash2mart/main.dart';

void main() {
  testWidgets('Flash2Mart app opens correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const Flash2MartApp());

    // Splash screen check
    expect(find.text('FLASH'), findsOneWidget);
    expect(find.text('2 MART'), findsOneWidget);

    // Splash timer complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Role selection screen check
    expect(find.text('Choose your role'), findsOneWidget);
  });
}
