import 'package:flutter_test/flutter_test.dart';
import 'package:product_explorer_assessment/features/products/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('SplashScreen smoke test displays brand name and tagline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('Productly'), findsOneWidget);
    expect(find.text("Discover products you'll love."), findsOneWidget);
  });
}
