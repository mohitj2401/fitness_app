import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_pass_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle(); // Wait for animations/futures

    // Verify that we are on the Home screen
    expect(find.text('Fitness Pass'), findsOneWidget);
    expect(find.text('Welcome back!'), findsOneWidget);
  });
}
