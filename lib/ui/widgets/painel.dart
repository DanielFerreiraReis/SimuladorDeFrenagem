import 'package:flutter/material.dart';

import '../tema.dart';

/// Cartão base da interface, com animação de entrada (surge de baixo).
class Painel extends StatelessWidget {
  const Painel({
    super.key,
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.child,
    this.acao,
    this.atraso = 0,
  });

  final String titulo;
  final IconData icone;
  final Color cor;
  final Widget child;
  final Widget? acao;
  final int atraso;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + atraso * 150),
      curve: Curves.easeOutCubic,
      builder: (context, valor, filho) => Opacity(
        opacity: valor,
        child: Transform.translate(
          offset: Offset(0, 28 * (1 - valor)),
          child: filho,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Paleta.superficie,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Paleta.borda),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cor.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icone, color: cor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Paleta.texto,
                    ),
                  ),
                ),
                if (acao != null) acao!,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
