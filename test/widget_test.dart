
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_edt/main.dart';

void main() {
  testWidgets('ImageEDT home screen displays correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ImageEDTApp(),
      ),
    );

    expect(find.text('ImageEDT'), findsOneWidget);
    expect(find.text('Your creative space'), findsOneWidget);
    expect(find.text('Open Gallery'), findsOneWidget);
  });
}
