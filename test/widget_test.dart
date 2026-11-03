import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_frenagem/app.dart';

void main() {
  testWidgets('a tela abre e responde aos controles', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AppFrenagem());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Simulador de Frenagem'), findsOneWidget);
    expect(find.text('Gelo'), findsOneWidget);

    await tester.tap(find.text('Gelo'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Resultados'), findsOneWidget);

    await tester.tap(find.text('Distância'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
