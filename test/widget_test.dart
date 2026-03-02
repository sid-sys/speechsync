import 'package:flutter_test/flutter_test.dart';
import 'package:speechsync/main.dart';

void main() {
  testWidgets('App starts and shows SpeechSync', (WidgetTester tester) async {
    await tester.pumpWidget(const SpeechSyncApp());
    // We start on the WelcomeScreen which should contain the text 'SpeechSync'
    expect(find.text('SpeechSync'), findsOneWidget);
  });
}
