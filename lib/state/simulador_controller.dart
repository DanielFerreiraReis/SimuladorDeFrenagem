import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../core/analise.dart';
import '../core/cenarios.dart';
import '../core/simulacao.dart';

/// Estado do simulador: parâmetros, resultados e o relógio da animação.
///
/// Só os pintores escutam [tempo] (a cada quadro); o resto da interface
/// escuta o próprio controlador, que só avisa quando algo muda de verdade.
class SimuladorController extends ChangeNotifier {
  SimuladorController(TickerProvider vsync) {
    _ticker = vsync.createTicker(_aoTique);
    _recalcular();
  }

  late final Ticker _ticker;
  Duration _ultimo = Duration.zero;

  /// Instante atual da animação, em segundos.
  final ValueNotifier<double> tempo = ValueNotifier<double>(0);

  Pista pista = Pista.seca;
  double coefEstatico = 1.0;
  double coefCinetico = 0.8;
  double passo = 0.1;
  double distanciaObstaculo = 5.0;
  double velocidadeReproducao = 1.0;
  bool tocando = false;

  late Resultado convencional;
  late Resultado comAbs;
  Impacto? impactoConvencional;
  Impacto? impactoAbs;

  /// Duração total da animação (parada mais 1 s para os efeitos finais).
  late double duracao;

  // ------------------------------------------------------------ parâmetros
  void selecionarPista(Pista nova) {
    pista = nova;
    final perfil = perfis[nova];
    if (perfil != null) {
      coefEstatico = perfil.coefEstatico;
      coefCinetico = perfil.coefCinetico;
    }
    _atualizar(tocarDepois: perfil != null);
  }

  void definirCoefEstatico(double valor) {
    coefEstatico = valor;
    if (coefCinetico > valor) coefCinetico = valor;
    pista = Pista.personalizada;
    _atualizar();
  }

  void definirCoefCinetico(double valor) {
    coefCinetico = valor;
    if (coefEstatico < valor) coefEstatico = valor;
    pista = Pista.personalizada;
    _atualizar();
  }

  void definirPasso(double valor) {
    passo = valor;
    _atualizar();
  }

  void definirObstaculo(double valor) {
    distanciaObstaculo = valor;
    _atualizar();
  }

  void definirVelocidade(double valor) {
    velocidadeReproducao = valor;
    notifyListeners();
  }

  // ------------------------------------------------------------ reprodução
  void tocar() {
    if (tempo.value >= duracao) tempo.value = 0;
    _ultimo = Duration.zero;
    if (!_ticker.isActive) _ticker.start();
    tocando = true;
    notifyListeners();
  }

  void pausar({bool notificar = true}) {
    if (_ticker.isActive) _ticker.stop();
    tocando = false;
    if (notificar) notifyListeners();
  }

  void alternar() => tocando ? pausar() : tocar();

  void reiniciar() {
    pausar(notificar: false);
    tempo.value = 0;
    notifyListeners();
  }

  void irPara(double instante) {
    pausar(notificar: false);
    tempo.value = instante.clamp(0.0, duracao).toDouble();
    notifyListeners();
  }

  // ------------------------------------------------------------ internos
  void _aoTique(Duration decorrido) {
    final dt = (decorrido - _ultimo).inMicroseconds / 1000000.0;
    _ultimo = decorrido;
    final proximo = tempo.value + dt * velocidadeReproducao;
    if (proximo >= duracao) {
      tempo.value = duracao;
      pausar();
    } else {
      tempo.value = proximo;
    }
  }

  void _recalcular() {
    convencional = simular(
      coefCinetico,
      coefEstatico,
      comAbs: false,
      passo: passo,
    );
    comAbs = simular(coefCinetico, coefEstatico, comAbs: true, passo: passo);
    impactoConvencional = calcularImpacto(convencional, distanciaObstaculo);
    impactoAbs = calcularImpacto(comAbs, distanciaObstaculo);
    duracao = max(convencional.tempoDeParada, comAbs.tempoDeParada) + 1.0;
    if (tempo.value > duracao) tempo.value = duracao;
  }

  void _atualizar({bool tocarDepois = false}) {
    _recalcular();
    pausar(notificar: false);
    tempo.value = 0;
    if (tocarDepois) {
      tocar();
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    tempo.dispose();
    super.dispose();
  }
}
