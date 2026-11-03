import 'package:flutter/material.dart';

import '../state/simulador_controller.dart';
import 'widgets/cabecalho.dart';
import 'widgets/painel_grafico.dart';
import 'widgets/painel_parametros.dart';
import 'widgets/painel_pista.dart';
import 'widgets/painel_resultados.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial>
    with SingleTickerProviderStateMixin {
  late final SimuladorController _controle;

  @override
  void initState() {
    super.initState();
    _controle = SimuladorController(this);
    _controle.tocar(); // começa freando assim que a tela abre
  }

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Cabecalho(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: LayoutBuilder(
                  builder: (context, restricoes) {
                    final largo = restricoes.maxWidth >= 1000;
                    final parametros = PainelParametros(controle: _controle);
                    final principal = <Widget>[
                      PainelPista(controle: _controle),
                      const SizedBox(height: 16),
                      PainelGrafico(controle: _controle),
                      const SizedBox(height: 16),
                      PainelResultados(controle: _controle),
                    ];
                    if (largo) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 360,
                              child: SingleChildScrollView(child: parametros),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(children: principal),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          parametros,
                          const SizedBox(height: 16),
                          ...principal,
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
