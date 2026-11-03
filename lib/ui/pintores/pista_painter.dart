import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/analise.dart';
import '../../core/cenarios.dart';
import '../../core/formatacao.dart';
import '../../core/simulacao.dart';
import '../tema.dart';
import 'util_pintura.dart';

/// Pista animada: dois robôs freando lado a lado, com obstáculo e impacto.
class PistaPainter extends CustomPainter {
  PistaPainter({
    required this.convencional,
    required this.comAbs,
    required this.impactoConvencional,
    required this.impactoAbs,
    required this.obstaculo,
    required this.pista,
    required this.tempo,
  }) : super(repaint: tempo);

  final Resultado convencional;
  final Resultado comAbs;
  final Impacto? impactoConvencional;
  final Impacto? impactoAbs;
  final double obstaculo;
  final Pista pista;
  final ValueListenable<double> tempo;

  static const double _comprimento = 50;

  @override
  void paint(Canvas canvas, Size size) {
    final t = tempo.value;
    const margemEsq = 12.0;
    const margemDir = 26.0;
    const topo = 2.0;
    const rodape = 44.0;
    const origem = margemEsq + _comprimento;
    final distanciaMax =
        max(
              max(convencional.distanciaDeParada, comAbs.distanciaDeParada),
              obstaculo,
            ) *
            1.1 +
        0.5;
    final pxPorMetro = (size.width - origem - margemDir) / distanciaMax;
    final alturaFaixa = (size.height - topo - rodape) / 2;

    _faixa(
      canvas,
      size,
      indice: 0,
      nome: 'Freio convencional (rodas travadas)',
      cor: Paleta.laranja,
      resultado: convencional,
      impacto: impactoConvencional,
      travadas: true,
      topo: topo,
      alturaFaixa: alturaFaixa,
      origem: origem,
      pxPorMetro: pxPorMetro,
      t: t,
    );
    _faixa(
      canvas,
      size,
      indice: 1,
      nome: 'Freio com ABS (rodas rolando)',
      cor: Paleta.ciano,
      resultado: comAbs,
      impacto: impactoAbs,
      travadas: false,
      topo: topo,
      alturaFaixa: alturaFaixa,
      origem: origem,
      pxPorMetro: pxPorMetro,
      t: t,
    );
    _regua(canvas, size, origem, pxPorMetro, distanciaMax, rodape);
  }

  void _faixa(
    Canvas canvas,
    Size size, {
    required int indice,
    required String nome,
    required Color cor,
    required Resultado resultado,
    required Impacto? impacto,
    required bool travadas,
    required double topo,
    required double alturaFaixa,
    required double origem,
    required double pxPorMetro,
    required double t,
  }) {
    final yTopo = topo + indice * alturaFaixa;
    final yChao = yTopo + alturaFaixa - 22;
    final retangulo = Rect.fromLTWH(0, yTopo, size.width, alturaFaixa - 6);
    final faixa = RRect.fromRectAndRadius(retangulo, const Radius.circular(14));

    final gelo = pista == Pista.gelo;
    canvas.drawRRect(
      faixa,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gelo
              ? const [Color(0xFF3B6EA5), Color(0xFF234B7A)]
              : const [Color(0xFF1F2937), Color(0xFF111827)],
        ).createShader(retangulo),
    );

    canvas.save();
    canvas.clipRRect(faixa);
    if (gelo) {
      final brilho = Paint()
        ..color = Colors.white.withAlpha(40)
        ..strokeWidth = 2;
      for (var k = 0; k < 14; k++) {
        final x = 30.0 + k * (size.width / 14);
        canvas.drawLine(
          Offset(x, yTopo + 14 + (k % 3) * 10),
          Offset(x + 18, yTopo + 8 + (k % 3) * 10),
          brilho,
        );
      }
    } else {
      desenharTracejado(
        canvas,
        Offset(0, yChao + 8),
        Offset(size.width, yChao + 8),
        Paint()
          ..color = Colors.white.withAlpha(35)
          ..strokeWidth = 2,
        traco: 18,
        espaco: 14,
      );
    }

    // estado atual do robô
    final distancia = interpolar(resultado.tempos, resultado.distancias, t);
    final velocidade = interpolar(resultado.tempos, resultado.velocidades, t);
    final tempoImpacto = impacto?.tempo ?? double.infinity;
    final velocidadeImpacto = impacto?.velocidade ?? 0.0;
    final bateu = t >= tempoImpacto;
    final distanciaEfetiva = bateu ? obstaculo : distancia;
    final velocidadeEfetiva = bateu ? 0.0 : velocidade;
    final parou = t >= resultado.tempoDeParada;
    final progresso = bateu
        ? ((t - tempoImpacto) / 0.8).clamp(0.0, 1.0).toDouble()
        : 1.0;

    var xFrente = origem + distanciaEfetiva * pxPorMetro;
    if (bateu && progresso < 1) {
      xFrente += sin(t * 90) * 3 * (1 - progresso);
    }
    final xObstaculo = origem + obstaculo * pxPorMetro;

    // marcas de pneu
    final marcaInicio = Offset(origem - 11, yChao + 1);
    final marcaFim = Offset(xFrente - 11, yChao + 1);
    if (travadas) {
      canvas.drawLine(
        marcaInicio,
        marcaFim,
        Paint()
          ..color = Colors.black.withAlpha(150)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    } else {
      desenharTracejado(
        canvas,
        marcaInicio,
        marcaFim,
        Paint()
          ..color = Colors.black.withAlpha(110)
          ..strokeWidth = 3,
        traco: 5,
        espaco: 6,
      );
    }

    // obstáculo listrado
    for (var k = 0; k < 6; k++) {
      canvas.drawRect(
        Rect.fromLTWH(xObstaculo + 2, yChao - 46 + k * 8.0, 10, 8),
        Paint()..color = k.isEven ? Paleta.vermelho : Colors.white,
      );
    }
    if (indice == 0) {
      desenharTexto(
        canvas,
        'obstáculo',
        Offset(xObstaculo + 7, yTopo + 8),
        tamanho: 10,
        cor: Paleta.vermelho,
        centralizar: true,
        peso: FontWeight.w600,
      );
    }

    // linhas de velocidade atrás do robô
    if (velocidadeEfetiva > 0.05) {
      final intensidade = velocidadeEfetiva / velocidadeInicial;
      for (var k = 0; k < 3; k++) {
        final y = yChao - 30 + k * 9.0;
        canvas.drawLine(
          Offset(xFrente - _comprimento - 6, y),
          Offset(
            xFrente - _comprimento - 6 - (6 + 26 * intensidade) * (1 - k * 0.2),
            y,
          ),
          Paint()
            ..color = Colors.white.withAlpha((90 * intensidade).round())
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // bandeira de parada (sem colisão)
    if (parou && impacto == null) {
      final haste = Paint()
        ..color = cor
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(xFrente + 6, yChao - 44),
        Offset(xFrente + 6, yChao),
        haste,
      );
      canvas.drawPath(
        Path()
          ..moveTo(xFrente + 6, yChao - 44)
          ..lineTo(xFrente + 20, yChao - 39)
          ..lineTo(xFrente + 6, yChao - 34)
          ..close(),
        Paint()..color = cor,
      );
    }

    // robô
    final pulso = 0.5 + 0.5 * sin(t * 2 * pi * 6);
    final Color aro;
    if (travadas) {
      aro = velocidadeEfetiva > 0.05 ? Paleta.vermelho : Paleta.textoSuave;
    } else {
      aro = velocidadeEfetiva > 0.05
          ? Color.lerp(Paleta.ciano, Colors.white, pulso)!
          : Paleta.textoSuave;
    }
    final anguloRoda = travadas ? 0.0 : (distanciaEfetiva * pxPorMetro) / 8;
    _robo(canvas, xFrente, yChao, cor, anguloRoda, aro);

    // impacto
    if (bateu) {
      final p = progresso;
      final centroImpacto = Offset(xObstaculo + 6, yChao - 24);
      canvas.drawRRect(
        faixa,
        Paint()..color = Paleta.vermelho.withAlpha((50 * (1 - p)).round()),
      );
      for (var k = 0; k < 2; k++) {
        canvas.drawCircle(
          centroImpacto,
          10 + 55 * p + k * 14,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = Paleta.vermelho.withAlpha(
              (255 * (1 - p) * (1 - k * 0.4)).round(),
            ),
        );
      }
      for (var k = 0; k < 8; k++) {
        final a = k * pi / 4;
        final dentro = 8 + 40 * p;
        final fora = 14 + 52 * p;
        canvas.drawLine(
          centroImpacto + Offset(cos(a), sin(a)) * dentro,
          centroImpacto + Offset(cos(a), sin(a)) * fora,
          Paint()
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round
            ..color = Paleta.ambar.withAlpha((255 * (1 - p)).round()),
        );
      }
    }
    canvas.restore();

    // rótulo com valores ao vivo
    final linhaAoVivo =
        '$nome  ·  v = ${fmt(velocidadeEfetiva)} m/s  ·  d = ${fmt(distanciaEfetiva)} m';
    desenharTexto(
      canvas,
      linhaAoVivo,
      Offset(12, yTopo + 8),
      tamanho: 11.5,
      cor: cor,
      peso: FontWeight.w600,
    );
    if (bateu) {
      desenharTexto(
        canvas,
        'IMPACTO  ${fmt(velocidadeImpacto)} m/s',
        Offset(xObstaculo - 10, yTopo + 24),
        tamanho: 11.5,
        cor: Paleta.vermelho,
        peso: FontWeight.bold,
        alinharDireita: true,
      );
    }
  }

  void _robo(
    Canvas canvas,
    double xFrente,
    double yChao,
    Color cor,
    double anguloRoda,
    Color aro,
  ) {
    final corpo = Rect.fromLTWH(
      xFrente - _comprimento,
      yChao - 34,
      _comprimento,
      22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(corpo, const Radius.circular(6)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cor, Color.alphaBlend(const Color(0x66000000), cor)],
        ).createShader(corpo),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(xFrente - 22, yChao - 30, 13, 8),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withAlpha(210),
    );
    canvas.drawCircle(
      Offset(xFrente - 5, yChao - 24),
      3,
      Paint()..color = Colors.white,
    );
    final antena = Paint()
      ..color = Colors.white.withAlpha(200)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(xFrente - 40, yChao - 34),
      Offset(xFrente - 40, yChao - 43),
      antena,
    );
    canvas.drawCircle(
      Offset(xFrente - 40, yChao - 44),
      2.2,
      Paint()..color = cor,
    );
    _roda(canvas, Offset(xFrente - 36, yChao - 8), anguloRoda, aro);
    _roda(canvas, Offset(xFrente - 12, yChao - 8), anguloRoda, aro);
  }

  void _roda(Canvas canvas, Offset centro, double angulo, Color aro) {
    canvas.drawCircle(centro, 8, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(
      centro,
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = aro,
    );
    final raio = Paint()
      ..color = aro.withAlpha(200)
      ..strokeWidth = 1.5;
    for (var k = 0; k < 2; k++) {
      final a = angulo + k * pi / 2;
      final d = Offset(cos(a), sin(a)) * 6;
      canvas.drawLine(centro - d, centro + d, raio);
    }
    canvas.drawCircle(centro, 1.8, Paint()..color = aro);
  }

  void _regua(
    Canvas canvas,
    Size size,
    double origem,
    double pxPorMetro,
    double distanciaMax,
    double rodape,
  ) {
    final yRegua = size.height - rodape + 8;
    final eixo = Paint()
      ..color = Paleta.textoSuave
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(origem, yRegua),
      Offset(size.width - 26, yRegua),
      eixo,
    );
    final passoRegua = distanciaMax <= 10
        ? 1.0
        : (distanciaMax <= 20 ? 2.0 : 5.0);
    for (var metro = 0.0; metro <= distanciaMax; metro += passoRegua) {
      final x = origem + metro * pxPorMetro;
      canvas.drawLine(Offset(x, yRegua), Offset(x, yRegua + 4), eixo);
      desenharTexto(
        canvas,
        metro.toStringAsFixed(0),
        Offset(x, yRegua + 5),
        centralizar: true,
        tamanho: 10,
      );
    }
    desenharTexto(
      canvas,
      'distância percorrida (m)',
      Offset(size.width - 26, yRegua + 18),
      alinharDireita: true,
      tamanho: 10,
    );
  }

  @override
  bool shouldRepaint(covariant PistaPainter antigo) => true;
}
