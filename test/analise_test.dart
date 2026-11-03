import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_frenagem/core/analise.dart';
import 'package:simulador_frenagem/core/simulacao.dart';

void main() {
  test('distâncias e tempos de parada batem com a Etapa 2 do trabalho', () {
    final secaConv = simular(0.8, 1.0, comAbs: false);
    final secaAbs = simular(0.8, 1.0, comAbs: true);
    final geloConv = simular(0.1, 0.15, comAbs: false);
    final geloAbs = simular(0.1, 0.15, comAbs: true);

    expect(secaConv.distanciaDeParada, closeTo(1.854, 0.0006));
    expect(secaAbs.distanciaDeParada, closeTo(1.530, 0.0006));
    expect(geloConv.distanciaDeParada, closeTo(13.005, 0.0006));
    expect(geloAbs.distanciaDeParada, closeTo(8.754, 0.0006));
    expect(secaConv.tempoDeParada, closeTo(0.7, 1e-9));
    expect(geloConv.tempoDeParada, closeTo(5.2, 1e-9));
    expect(geloAbs.tempoDeParada, closeTo(3.5, 1e-9));
  });

  test('impacto com obstáculo a 5 m', () {
    expect(calcularImpacto(simular(0.8, 1.0, comAbs: false), 5), isNull);
    final abs = calcularImpacto(simular(0.1, 0.15, comAbs: true), 5);
    final conv = calcularImpacto(simular(0.1, 0.15, comAbs: false), 5);
    expect(abs, isNotNull);
    expect(conv, isNotNull);
    expect(conv!.velocidade, greaterThan(abs!.velocidade));
  });

  test('velocidade nunca fica negativa', () {
    final r = simular(0.1, 0.15, comAbs: false, passo: 0.001);
    expect(r.velocidades.every((v) => v >= 0), isTrue);
  });
}
