import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:museum/app/museum_app.dart';
import 'package:museum/data/demo_museum.dart';

void main() {
  testWidgets('Navega de Home a Sala', (WidgetTester tester) async {
    await tester.pumpWidget(
      MuseumApp(repository: const DemoMuseumRepository()),
    );
    expect(find.text('Museo'), findsOneWidget);

    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('room_card_sala-origen')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sala Origen'), findsOneWidget);
  });
}
