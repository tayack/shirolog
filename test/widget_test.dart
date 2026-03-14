import 'package:flutter_test/flutter_test.dart';
import 'package:shirolog/main.dart';

void main() {
  testWidgets('ShiroLogApp smoke test', (WidgetTester tester) async {
    // アプリを起動
    await tester.pumpWidget(const ShiroLogApp());

    // 「城Log」というテキストが表示されているか確認
    expect(find.text('城Log'), findsWidgets);
  });
}
