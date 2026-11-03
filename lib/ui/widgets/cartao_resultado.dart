import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/analise.dart';
import '../../core/formatacao.dart';
import '../../core/simulacao.dart';
import '../tema.dart';

/// Resultado de um dos freios: números animados, situação diante do
/// obstáculo e velocidade ao vivo.
class CartaoResultado extends StatelessWidget {
  const CartaoResultado({
    super.key,
    required this.titulo,
    required this.cor,
    required this.resultado,
    required this.impacto,
    required this.obstaculo,
    required this.tempo,
  });

  final String titulo;
  final Color cor;
  final Resultado resultado;
  final Impacto? impacto;
  final double obstaculo;
  final ValueListenable<double> tempo;

  @override
  Widget build(BuildContext context) {
    final colisao = impacto;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withAlpha(22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withAlpha(110)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(color: cor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: resultado.distanciaDeParada),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, valor, _) => Text(
              '${fmt(valor, 3)} m',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Paleta.texto,
              ),
            ),
          ),
          const Text(
            'distância de parada',
            style: TextStyle(fontSize: 12, color: Paleta.textoSuave),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: resultado.tempoDeParada),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, valor, _) => Text(
              '${fmt(valor, 1)} s',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Paleta.texto,
              ),
            ),
          ),
          const Text(
            'tempo de parada',
            style: TextStyle(fontSize: 12, color: Paleta.textoSuave),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(
              key: ValueKey<bool>(colisao != null),
              child: colisao != null
                  ? _Selo(
                      cor: Paleta.vermelho,
                      icone: Icons.warning_amber_rounded,
                      texto:
                          'Colisão a ${fmt(colisao.velocidade)} m/s · ${fmt(colisao.energia, 1)} J',
                    )
                  : _Selo(
                      cor: Paleta.verde,
                      icone: Icons.check_circle_outline,
                      texto:
                          'Para ${fmt(obstaculo - resultado.distanciaDeParada)} m antes do obstáculo',
                    ),
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<double>(
            valueListenable: tempo,
            builder: (context, t, _) {
              final parouNoImpacto = colisao != null && t >= colisao.tempo;
              final v = parouNoImpacto
                  ? 0.0
                  : interpolar(resultado.tempos, resultado.velocidades, t);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'velocidade agora: ${fmt(v)} m/s',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Paleta.textoSuave,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (v / velocidadeInicial).clamp(0.0, 1.0).toDouble(),
                      minHeight: 8,
                      color: cor,
                      backgroundColor: Paleta.borda,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Selo extends StatelessWidget {
  const _Selo({required this.cor, required this.icone, required this.texto});

  final Color cor;
  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cor.withAlpha(35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icone, size: 18, color: cor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: cor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
