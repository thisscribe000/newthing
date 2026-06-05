import 'package:flutter_test/flutter_test.dart';
import 'package:waveline/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const WavelineApp());
    expect(find.byType(WavelineApp), findsOneWidget);
  });
}
