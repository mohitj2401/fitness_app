import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_pass_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitnessApp(onboardingComplete: false));
    await tester.pumpAndSettle(); // Wait for animations/futures

    // Verify that we are on the Onboarding screen
    expect(find.textContaining('Fitness Pass'), findsOneWidget);
  });
}
