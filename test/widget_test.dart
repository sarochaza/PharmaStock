import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phamory/app.dart';

void main() {
  testWidgets('PhamoryApp builds without crashing',
      (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const PhamoryApp());

    // Wait for first frame
    await tester.pump();

    // ตรวจสอบว่า MaterialApp ถูกสร้าง
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}