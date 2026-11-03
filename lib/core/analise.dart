import 'simulacao.dart';

/// Valor de uma série amostrada em [tempos] no instante [t] (interpolação linear).
double interpolar(List<double> tempos, List<double> valores, double t) {
  if (t <= 0) return valores.first;
  if (t >= tempos.last) return valores.last;
  final passo = tempos[1] - tempos[0];
  var i = (t / passo).floor();
  if (i >= tempos.length - 1) i = tempos.length - 2;
  final fracao = (t - tempos[i]) / (tempos[i + 1] - tempos[i]);
  return valores[i] + (valores[i + 1] - valores[i]) * fracao;
}

/// Distância de parada analítica: velocidade inicial² / (2 · μ · gravidade).
double distanciaAnalitica(double coefAtrito) =>
    velocidadeInicial * velocidadeInicial / (2 * coefAtrito * gravidade);

/// Colisão com o obstáculo: instante, velocidade e energia no impacto.
class Impacto {
  const Impacto(this.tempo, this.velocidade, this.energia);
  final double tempo, velocidade, energia;
}

/// Devolve o impacto, ou `null` se o robô para antes do obstáculo.
Impacto? calcularImpacto(Resultado r, double distanciaObstaculo) {
  if (r.distanciaDeParada <= distanciaObstaculo) return null;
  for (var i = 0; i < r.distancias.length - 1; i++) {
    if (r.distancias[i + 1] >= distanciaObstaculo) {
      final trecho = r.distancias[i + 1] - r.distancias[i];
      final fracao = trecho == 0
          ? 0.0
          : (distanciaObstaculo - r.distancias[i]) / trecho;
      final tempo = r.tempos[i] + fracao * (r.tempos[i + 1] - r.tempos[i]);
      final velocidade =
          r.velocidades[i] + fracao * (r.velocidades[i + 1] - r.velocidades[i]);
      return Impacto(tempo, velocidade, 0.5 * massa * velocidade * velocidade);
    }
  }
  return null;
}

/// Imprime a comparação final (Quadro 4 do trabalho).
void imprimirComparacao(void Function(String) saida) {
  const pistas = {
    'seca': [0.8, 1.0],
    'gelo': [0.1, 0.15],
  };
  pistas.forEach((nome, coef) {
    final convencional = simular(coef[0], coef[1], comAbs: false);
    final abs = simular(coef[0], coef[1], comAbs: true);
    final ganho =
        100 * (1 - abs.distanciaDeParada / convencional.distanciaDeParada);
    saida(
      '$nome | convencional: '
      '${convencional.tempoDeParada.toStringAsFixed(1)} s, '
      '${convencional.distanciaDeParada.toStringAsFixed(3)} m | ABS: '
      '${abs.tempoDeParada.toStringAsFixed(1)} s, '
      '${abs.distanciaDeParada.toStringAsFixed(3)} m | '
      'redução: ${ganho.toStringAsFixed(1)}%',
    );
  });
}
