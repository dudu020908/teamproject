import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/main.dart';
import 'package:teamproject/screens/winner_screen.dart';

void main() {
  testWidgets('WinnerScreen shows fallback when arguments are missing',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeModeNotifier(),
        child: const MaterialApp(
          home: WinnerScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text(WinnerScreen.missingArgumentMessage),
      findsOneWidget,
    );
  });
}