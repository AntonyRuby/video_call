import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_call_app/main.dart';

void main() {
  testWidgets('Video Call App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(VideoCallApp());

    // Verify that the app starts with the CallScreen.
    expect(find.text('Video Call'), findsOneWidget);
    expect(find.text('Video Call Screen'), findsOneWidget);
  });
}
