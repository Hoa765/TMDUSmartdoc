import 'package:flutter_test/flutter_test.dart';

import 'package:tdmu_smartdocs/main.dart';

void main() {
  testWidgets('shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TdmuSmartDocApp());

    expect(find.text('TDMU SmartDoc'), findsOneWidget);
    expect(find.text('Your AI Learning Assistant'), findsOneWidget);
  });
}
