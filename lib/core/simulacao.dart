import 'dart:math';

const double massa = 10, gravidade = 9.8;
const double velocidadeInicial = 5, forcaPedal = 150;

class Resultado {
  final List<double> tempos, velocidades, distancias;
  Resultado(this.tempos, this.velocidades, this.distancias);
  double get tempoDeParada => tempos.last;
  double get distanciaDeParada => distancias.last;
}

/// Frenagem em linha reta, integrada pelo método de Euler.
Resultado simular(
  double coefCinetico,
  double coefEstatico, {
  required bool comAbs,
  double passo = 0.1,
}) {
  const normal = massa * gravidade;
  final atritoEstaticoMax = coefEstatico * normal; // roda rolando
  final atritoCinetico = coefCinetico * normal; // rodas travadas
  var velocidade = velocidadeInicial, distancia = 0.0, passos = 0;
  final tempos = [0.0], velocidades = [velocidade], distancias = [distancia];

  while (velocidade > 0) {
    final double atrito;
    if (forcaPedal > atritoEstaticoMax) {
      // a roda travaria
      atrito = comAbs ? atritoEstaticoMax : atritoCinetico;
    } else {
      atrito = forcaPedal;
    }
    final aceleracao = -atrito / massa; // segunda lei de Newton
    // Euler: avança distância e velocidade
    distancia += velocidade * passo;
    velocidade = max(velocidade + aceleracao * passo, 0.0);
    passos++;
    tempos.add(passos * passo);
    velocidades.add(velocidade);
    distancias.add(distancia);
  }
  return Resultado(tempos, velocidades, distancias);
}
