// Verificação do núcleo em Dart puro (não precisa do Flutter):
//   dart tool/verificar.dart
import 'dart:math';

import 'package:simulador_frenagem/core/analise.dart';
import 'package:simulador_frenagem/core/simulacao.dart';

void verificar(bool condicao, String mensagem) {
  if (!condicao) throw StateError('FALHOU: $mensagem');
  print('ok  - $mensagem');
}

bool perto(double a, double b, [double tolerancia = 0.0006]) =>
    (a - b).abs() <= tolerancia;

void main() {
  final secaConv = simular(0.8, 1.0, comAbs: false);
  final secaAbs = simular(0.8, 1.0, comAbs: true);
  final geloConv = simular(0.1, 0.15, comAbs: false);
  final geloAbs = simular(0.1, 0.15, comAbs: true);

  verificar(
    perto(secaConv.distanciaDeParada, 1.854),
    'seca, convencional: 1,854 m',
  );
  verificar(perto(secaAbs.distanciaDeParada, 1.530), 'seca, ABS: 1,530 m');
  verificar(
    perto(geloConv.distanciaDeParada, 13.005),
    'gelo, convencional: 13,005 m',
  );
  verificar(perto(geloAbs.distanciaDeParada, 8.754), 'gelo, ABS: 8,754 m');
  verificar(
    perto(secaConv.tempoDeParada, 0.7, 1e-9),
    'seca, convencional: 0,7 s',
  );
  verificar(
    perto(geloConv.tempoDeParada, 5.2, 1e-9),
    'gelo, convencional: 5,2 s',
  );
  verificar(perto(geloAbs.tempoDeParada, 3.5, 1e-9), 'gelo, ABS: 3,5 s');

  verificar(
    perto(distanciaAnalitica(0.8), 1.594),
    'analítica seca convencional: 1,594 m',
  );
  verificar(
    perto(distanciaAnalitica(0.15), 8.503),
    'analítica gelo ABS: 8,503 m',
  );

  verificar(
    calcularImpacto(secaConv, 5) == null,
    'seca não colide com obstáculo a 5 m',
  );
  final i = calcularImpacto(geloAbs, 5);
  verificar(i != null, 'gelo com ABS colide com obstáculo a 5 m');
  verificar(
    perto(i!.energia, 0.5 * massa * pow(i.velocidade, 2).toDouble(), 1e-9),
    'energia no impacto = 1/2 · massa · velocidade²',
  );
  final j = calcularImpacto(geloConv, 5)!;
  verificar(j.velocidade > i.velocidade, 'sem ABS o impacto é mais forte');

  for (final v in [secaConv, secaAbs, geloConv, geloAbs]) {
    verificar(
      v.velocidades.every((x) => x >= 0),
      'velocidade nunca fica negativa',
    );
  }
  print('\nTudo certo.');
}
