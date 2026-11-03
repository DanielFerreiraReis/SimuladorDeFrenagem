import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/analise.dart';
import '../../core/formatacao.dart';
import '../../core/simulacao.dart';
import '../tema.dart';
import 'util_pintura.dart';

enum Grandeza { velocidade, distancia }

/// Gráfico das duas frenagens, com cursor sincronizado com a animação.
class GraficoPainter extends CustomPainter {
  GraficoPainter({
    required this.convencional,
    required this.comAbs,
    required this.impactoConvencional,
    required this.impactoAbs,
    required this.obstaculo,
    required this.grandeza,
    required this.tempo,
  }) : super(repaint: tempo);

  final Resultado convencional;
  final Resultado comAbs;
  final Impacto? impactoConvencional;
  final Impacto? impactoAbs;
  final double obstaculo;
  final Grandeza grandeza;
  final ValueListenable<double> tempo;

  List<double> _serie(Resultado r) =>
      grandeza == Grandeza.velocidade ? r.velocidades : r.distancias;

  @override
  void paint(Canvas canvas, Size size) {
    final t = tempo.value;
    const esq = 52.0, dir = 16.0, topo = 30.0, base = 40.0;
    final largura = size.width - esq - dir;
    final altura = size.height - topo - base;
    final tempoMax = max(convencional.tempoDeParada, comAbs.tempoDeParada);
    final ehVelocidade = grandeza == Grandeza.velocidade;
    final valorMax = ehVelocidade
        ? velocidadeInicial
        : max(
                max(convencional.distanciaDeParada, comAbs.distanciaDeParada),
                obstaculo,
              ) *
              1.1;

    Offset ponto(double tt, double vv) => Offset(
      esq + tt / tempoMax * largura,
      topo + altura - vv / valorMax * altura,
    );

    // grade
    final grade = Paint()
      ..color = Paleta.borda
      ..strokeWidth = 1;
    for (var i = 0; i <= 5; i++) {
      final y = topo + altura * i / 5;
      canvas.drawLine(Offset(esq, y), Offset(esq + largura, y), grade);
      desenharTexto(
        canvas,
        fmt(valorMax * (5 - i) / 5, 1),
        Offset(esq - 8, y - 7),
        alinharDireita: true,
        tamanho: 10,
      );
      final x = esq + largura * i / 5;
      canvas.drawLine(Offset(x, topo), Offset(x, topo + altura), grade);
      desenharTexto(
        canvas,
        fmt(tempoMax * i / 5, 1),
        Offset(x, topo + altura + 6),
        centralizar: true,
        tamanho: 10,
      );
    }
    desenharTexto(
      canvas,
      'tempo (s)',
      Offset(esq + largura / 2, size.height - 16),
      centralizar: true,
      tamanho: 10,
    );
    desenharTexto(
      canvas,
      ehVelocidade ? 'velocidade (m/s)' : 'distância percorrida (m)',
      const Offset(0, 6),
      tamanho: 10.5,
    );
    desenharTexto(
      canvas,
      '● ABS',
      Offset(size.width - dir, 6),
      cor: Paleta.ciano,
      peso: FontWeight.bold,
      alinharDireita: true,
    );
    desenharTexto(
      canvas,
      '● convencional',
      Offset(size.width - dir - 62, 6),
      cor: Paleta.laranja,
      peso: FontWeight.bold,
      alinharDireita: true,
    );

    // obstáculo (modo distância)
    if (!ehVelocidade) {
      final y = ponto(0, obstaculo).dy;
      desenharTracejado(
        canvas,
        Offset(esq, y),
        Offset(esq + largura, y),
        Paint()
          ..color = Paleta.vermelho
          ..strokeWidth = 1.6,
      );
      desenharTexto(
        canvas,
        'obstáculo (${fmt(obstaculo, 1)} m)',
        Offset(esq + 6, y - 15),
        cor: Paleta.vermelho,
        tamanho: 10.5,
        peso: FontWeight.w600,
      );
    }

    // curvas
    void curva(Resultado r, Color cor) {
      const n = 240;
      final serie = _serie(r);
      final linha = Path();
      final area = Path();
      for (var i = 0; i <= n; i++) {
        final tt = tempoMax * i / n;
        final p = ponto(tt, interpolar(r.tempos, serie, tt));
        if (i == 0) {
          linha.moveTo(p.dx, p.dy);
          area.moveTo(p.dx, topo + altura);
          area.lineTo(p.dx, p.dy);
        } else {
          linha.lineTo(p.dx, p.dy);
          area.lineTo(p.dx, p.dy);
        }
      }
      area.lineTo(esq + largura, topo + altura);
      area.close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cor.withAlpha(60), cor.withAlpha(0)],
          ).createShader(Rect.fromLTWH(esq, topo, largura, altura)),
      );
      canvas.drawPath(
        linha,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeJoin = StrokeJoin.round
          ..color = cor.withAlpha(40),
      );
      canvas.drawPath(
        linha,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8
          ..strokeJoin = StrokeJoin.round
          ..color = cor,
      );
    }

    curva(convencional, Paleta.laranja);
    curva(comAbs, Paleta.ciano);

    // marcas de impacto
    void marcaImpacto(Impacto? impacto) {
      if (impacto == null) return;
      final p = ponto(
        impacto.tempo,
        ehVelocidade ? impacto.velocidade : obstaculo,
      );
      canvas.drawCircle(p, 7, Paint()..color = Paleta.vermelho.withAlpha(60));
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Paleta.vermelho,
      );
    }

    marcaImpacto(impactoConvencional);
    marcaImpacto(impactoAbs);

    // cursor sincronizado com a animação
    final instante = min(t, tempoMax);
    final xCursor = ponto(instante, 0).dx;
    canvas.drawLine(
      Offset(xCursor, topo),
      Offset(xCursor, topo + altura),
      Paint()
        ..color = Colors.white.withAlpha(110)
        ..strokeWidth = 1.5,
    );
    void bolinha(Resultado r, Color cor) {
      final tt = min(instante, r.tempoDeParada);
      final p = ponto(tt, interpolar(r.tempos, _serie(r), tt));
      canvas.drawCircle(p, 6, Paint()..color = Paleta.fundo);
      canvas.drawCircle(
        p,
        6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = cor,
      );
    }

    bolinha(convencional, Paleta.laranja);
    bolinha(comAbs, Paleta.ciano);
  }

  @override
  bool shouldRepaint(covariant GraficoPainter antigo) => true;
}
