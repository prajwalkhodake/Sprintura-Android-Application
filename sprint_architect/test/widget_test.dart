import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_architect/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const SprinturaApp());
    // Verify the app loads
    expect(find.text('SPRINTURA'), findsOneWidget);
  });
}
