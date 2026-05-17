import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_architect/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const SprintArchitectApp());
    // Verify the app loads
    expect(find.text('Sprint'), findsOneWidget);
    expect(find.text('ARCHITECT'), findsOneWidget);
  });
}
