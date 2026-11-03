import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/analise.dart';

void main() {
  // Em modo de depuração, imprime no console a comparação do Quadro 4.
  if (kDebugMode) imprimirComparacao(debugPrint);
  runApp(const AppFrenagem());
}
