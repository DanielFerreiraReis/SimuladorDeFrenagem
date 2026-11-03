import 'package:flutter/material.dart';

import '../../state/simulador_controller.dart';
import '../pintores/grafico_painter.dart';
import '../tema.dart';
import 'painel.dart';

class PainelGrafico extends StatefulWidget {
  const PainelGrafico({super.key, required this.controle});

  final SimuladorController controle;

  @override
  State<PainelGrafico> createState() => _PainelGraficoState();
}

class _PainelGraficoState extends State<PainelGrafico> {
  Grandeza _grandeza = Grandeza.velocidade;

  Widget _opcao(String rotulo, Grandeza valor) {
    final ativa = _grandeza == valor;
    return ChoiceChip(
      label: Text(rotulo),
      selected: ativa,
      showCheckmark: false,
      onSelected: (_) => setState(() => _grandeza = valor),
      selectedColor: Paleta.laranja.withAlpha(60),
      backgroundColor: Paleta.superficieAlta,
      side: BorderSide(color: ativa ? Paleta.laranja : Paleta.borda),
      labelStyle: TextStyle(
        color: ativa ? Paleta.laranja : Paleta.textoSuave,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controle = widget.controle;
    return Painel(
      titulo: 'Gráfico',
      icone: Icons.show_chart,
      cor: Paleta.laranja,
      atraso: 2,
      acao: Wrap(
        spacing: 6,
        children: [
          _opcao('Velocidade', Grandeza.velocidade),
          _opcao('Distância', Grandeza.distancia),
        ],
      ),
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: controle,
            builder: (context, _) => CustomPaint(
              size: Size.infinite,
              painter: GraficoPainter(
                convencional: controle.convencional,
                comAbs: controle.comAbs,
                impactoConvencional: controle.impactoConvencional,
                impactoAbs: controle.impactoAbs,
                obstaculo: controle.distanciaObstaculo,
                grandeza: _grandeza,
                tempo: controle.tempo,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
