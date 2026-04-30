import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calliope_fm/main.dart';

void main() {
  testWidgets('App smoke test — renders without error', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CalliopeApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}