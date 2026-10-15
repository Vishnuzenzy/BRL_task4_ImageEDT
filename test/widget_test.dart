import 'package:flutter_test/flutter_test.dart';
import 'package:image_edt/main.dart';

void main() {
  testWidgets('ImageEDT app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ImageEDTApp());

    expect(find.text('ImageEDT'), findsOneWidget);
    expect(find.text('Your creative space'), findsOneWidget);
    expect(find.text('Open Gallery'), findsOneWidget);
    expect(find.text('Quick tools'), findsOneWidget);
  });
}