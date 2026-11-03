import 'package:flutter/material.dart';

import '../../core/formatacao.dart';
import '../../state/simulador_controller.dart';
import '../pintores/pista_painter.dart';
import '../tema.dart';
import 'painel.dart';

class PainelPista extends StatelessWidget {
  const PainelPista({super.key, required this.controle});

  final SimuladorController controle;

  @override
  Widget build(BuildContext context) {
    return Painel(
      titulo: 'Pista',
      icone: Icons.route,
      cor: Paleta.ciano,
      atraso: 1,
      child: Column(
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: controle,
                builder: (context, _) => CustomPaint(
                  size: Size.infinite,
                  painter: PistaPainter(
                    convencional: controle.convencional,
                    comAbs: controle.comAbs,
                    impactoConvencional: controle.impactoConvencional,
                    impactoAbs: controle.impactoAbs,
                    obstaculo: controle.distanciaObstaculo,
                    pista: controle.pista,
                    tempo: controle.tempo,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _LinhaDoTempo(controle: controle),
        ],
      ),
    );
  }
}

class _LinhaDoTempo extends StatelessWidget {
  const _LinhaDoTempo({required this.controle});

  final SimuladorController controle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controle, controle.tempo]),
      builder: (context, _) {
        final t = controle.tempo.value;
        return Row(
          children: [
            IconButton(
              onPressed: controle.alternar,
              color: Paleta.ciano,
              icon: Icon(controle.tocando ? Icons.pause : Icons.play_arrow),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Paleta.ciano,
                  thumbColor: Paleta.ciano,
                  inactiveTrackColor: Paleta.borda,
                  overlayColor: Paleta.ciano.withAlpha(40),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: t.clamp(0.0, controle.duracao).toDouble(),
                  min: 0,
                  max: controle.duracao,
                  onChanged: controle.irPara,
                ),
              ),
            ),
            SizedBox(
              width: 64,
              child: Text(
                '${fmt(t)} s',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Paleta.textoSuave,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
