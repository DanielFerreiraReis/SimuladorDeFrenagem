import 'package:flutter/material.dart';

import '../tema.dart';

void desenharTexto(
  Canvas canvas,
  String texto,
  Offset posicao, {
  double tamanho = 11,
  Color cor = Paleta.textoSuave,
  FontWeight peso = FontWeight.normal,
  bool centralizar = false,
  bool alinharDireita = false,
}) {
  final pintor = TextPainter(
    text: TextSpan(
      text: texto,
      style: TextStyle(fontSize: tamanho, color: cor, fontWeight: peso),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  var x = posicao.dx;
  if (centralizar) x -= pintor.width / 2;
  if (alinharDireita) x -= pintor.width;
  pintor.paint(canvas, Offset(x, posicao.dy));
}

void desenharTracejado(
  Canvas canvas,
  Offset a,
  Offset b,
  Paint tinta, {
  double traco = 6,
  double espaco = 4,
}) {
  final total = (b - a).distance;
  if (total == 0) return;
  final direcao = (b - a) / total;
  var percorrido = 0.0;
  while (percorrido < total) {
    final fim = (percorrido + traco).clamp(0.0, total).toDouble();
    canvas.drawLine(a + direcao * percorrido, a + direcao * fim, tinta);
    percorrido += traco + espaco;
  }
}
