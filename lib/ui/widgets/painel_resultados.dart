import 'package:flutter/material.dart';

import '../../core/analise.dart';
import '../../core/formatacao.dart';
import '../../core/simulacao.dart';
import '../../state/simulador_controller.dart';
import '../tema.dart';
import 'cartao_resultado.dart';
import 'painel.dart';

class PainelResultados extends StatelessWidget {
  const PainelResultados({super.key, required this.controle});

  final SimuladorController controle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controle,
      builder: (context, _) {
        final conv = controle.convencional;
        final abs = controle.comAbs;
        final reducao =
            100 * (1 - abs.distanciaDeParada / conv.distanciaDeParada);
        final semGanho = reducao.abs() < 0.05;
        final analitica = distanciaAnalitica(controle.coefCinetico);
        final erro = 100 * (conv.distanciaDeParada - analitica) / analitica;
        final ic = controle.impactoConvencional;
        final ia = controle.impactoAbs;

        final cartaoConv = CartaoResultado(
          titulo: 'Freio convencional',
          cor: Paleta.laranja,
          resultado: conv,
          impacto: ic,
          obstaculo: controle.distanciaObstaculo,
          tempo: controle.tempo,
        );
        final cartaoAbs = CartaoResultado(
          titulo: 'Freio com ABS',
          cor: Paleta.ciano,
          resultado: abs,
          impacto: ia,
          obstaculo: controle.distanciaObstaculo,
          tempo: controle.tempo,
        );

        String mensagem;
        if (semGanho) {
          mensagem =
              'Sem ganho: com μe = μc, manter a roda no limite estático '
              'não freia mais do que travá-la.';
        } else {
          mensagem =
              'O ABS reduz a distância de parada em ${fmt(reducao, 1)}%.';
          if (ic != null && ia != null && ic.energia > 0) {
            final queda = 100 * (1 - ia.energia / ic.energia);
            mensagem +=
                ' Energia no impacto: ${fmt(ic.energia, 1)} J → '
                '${fmt(ia.energia, 1)} J (−${fmt(queda, 0)}%).';
          }
        }

        return Painel(
          titulo: 'Resultados',
          icone: Icons.analytics_outlined,
          cor: Paleta.verde,
          atraso: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, restricoes) {
                  if (restricoes.maxWidth >= 520) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cartaoConv),
                        const SizedBox(width: 14),
                        Expanded(child: cartaoAbs),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      cartaoConv,
                      const SizedBox(height: 14),
                      cartaoAbs,
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      (semGanho ? Paleta.ambar : Paleta.verde).withAlpha(50),
                      (semGanho ? Paleta.ambar : Paleta.verde).withAlpha(18),
                    ],
                  ),
                ),
                child: Text(
                  mensagem,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: semGanho ? Paleta.ambar : Paleta.verde,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Distância analítica (convencional): ${fmt(analitica, 3)} m · '
                'erro do Euler com Δt = ${fmt(controle.passo, 3)} s: ${fmt(erro, 1)}%. '
                'Parâmetros fixos: massa ${massa.toStringAsFixed(0)} kg, '
                'velocidade inicial ${velocidadeInicial.toStringAsFixed(0)} m/s, '
                'força de frenagem ${forcaPedal.toStringAsFixed(0)} N.',
                style: const TextStyle(fontSize: 12, color: Paleta.textoSuave),
              ),
            ],
          ),
        );
      },
    );
  }
}
