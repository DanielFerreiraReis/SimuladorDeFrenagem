import 'package:flutter/material.dart';

import 'ui/tela_inicial.dart';
import 'ui/tema.dart';

class AppFrenagem extends StatelessWidget {
  const AppFrenagem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simulador de Frenagem',
      theme: construirTema(),
      home: const TelaInicial(),
    );
  }
}
