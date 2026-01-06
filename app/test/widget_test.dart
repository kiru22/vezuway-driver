import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistics_app/app.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LogisticsApp(),
      ),
    );

    await tester.pump();
    expect(find.text('vezuway.'), findsWidgets);
  });
}
