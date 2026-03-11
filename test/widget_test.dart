import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:museum/app/museum_app.dart';

void main() {
  testWidgets('Navega de Home a Sala', (WidgetTester tester) async {
    await tester.pumpWidget(const MuseumApp());
    expect(find.text('Museo'), findsOneWidget);

    // En el demo, la primera sala es "Sala Origen".
    await tester.tap(
      find.byKey(const ValueKey<String>('room_card_sala-origen')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sala Origen'), findsOneWidget);
  });
}
