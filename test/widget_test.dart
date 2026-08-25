import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creators_grow/app/app.dart';

void main() {
  testWidgets('App load splash text smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    expect(find.text('CreatorsGrow Splash Foundation'), findsOneWidget);
  });
}
