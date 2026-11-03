import 'package:flutter/material.dart';

/// Paleta única do aplicativo (mesmo código de cores do trabalho).
class Paleta {
  static const fundo = Color(0xFF0B1220);
  static const superficie = Color(0xFF111A2E);
  static const superficieAlta = Color(0xFF16223B);
  static const borda = Color(0xFF22304F);
  static const texto = Color(0xFFE2E8F0);
  static const textoSuave = Color(0xFF94A3B8);

  static const azul = Color(0xFF3B82F6);
  static const ciano = Color(0xFF22D3EE); // freio com ABS
  static const laranja = Color(0xFFFB923C); // freio convencional
  static const verde = Color(0xFF4ADE80);
  static const violeta = Color(0xFFA78BFA);
  static const ambar = Color(0xFFFBBF24);
  static const vermelho = Color(0xFFF87171);
}

ThemeData construirTema() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: Paleta.azul,
    scaffoldBackgroundColor: Paleta.fundo,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Paleta.texto,
      displayColor: Paleta.texto,
    ),
  );
}
