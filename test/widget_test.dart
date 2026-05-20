import 'package:flutter_test/flutter_test.dart';
import 'package:electronics_manager/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ElectronicsManagerApp());

    // Verify that our app starts and shows the title.
    expect(find.text('Electronics Inventory'), findsOneWidget);
  });
}
