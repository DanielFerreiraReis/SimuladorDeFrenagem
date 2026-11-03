import 'package:flutter/material.dart';

import '../../core/cenarios.dart';
import '../../core/formatacao.dart';
import '../../state/simulador_controller.dart';
import '../tema.dart';
import 'painel.dart';

class PainelParametros extends StatelessWidget {
  const PainelParametros({super.key, required this.controle});

  final SimuladorController controle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controle,
      builder: (context, _) {
        return Painel(
          titulo: 'Parâmetros',
          icone: Icons.tune,
          cor: Paleta.azul,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Secao('Pista'),
              Row(
                children: [
                  Expanded(
                    child: _CartaoPista(
                      icone: Icons.wb_sunny_outlined,
                      titulo: 'Seca',
                      cor: Paleta.ambar,
                      selecionado: controle.pista == Pista.seca,
                      aoToque: () => controle.selecionarPista(Pista.seca),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CartaoPista(
                      icone: Icons.ac_unit,
                      titulo: 'Gelo',
                      cor: Paleta.ciano,
                      selecionado: controle.pista == Pista.gelo,
                      aoToque: () => controle.selecionarPista(Pista.gelo),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CartaoPista(
                      icone: Icons.tune,
                      titulo: 'Livre',
                      cor: Paleta.violeta,
                      selecionado: controle.pista == Pista.personalizada,
                      aoToque: () =>
                          controle.selecionarPista(Pista.personalizada),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Controle(
                rotulo: 'Atrito estático (μe)',
                valor: controle.coefEstatico,
                minimo: 0.05,
                maximo: 1.2,
                divisoes: 115,
                cor: Paleta.laranja,
                texto: fmt(controle.coefEstatico),
                aoMudar: controle.definirCoefEstatico,
              ),
              _Controle(
                rotulo: 'Atrito cinético (μc)',
                valor: controle.coefCinetico,
                minimo: 0.05,
                maximo: 1.2,
                divisoes: 115,
                cor: Paleta.laranja,
                texto: fmt(controle.coefCinetico),
                aoMudar: controle.definirCoefCinetico,
              ),
              _Controle(
                rotulo: 'Distância ao obstáculo',
                valor: controle.distanciaObstaculo,
                minimo: 1,
                maximo: 15,
                divisoes: 28,
                cor: Paleta.vermelho,
                texto: '${fmt(controle.distanciaObstaculo, 1)} m',
                aoMudar: controle.definirObstaculo,
              ),
              const SizedBox(height: 4),
              const _Secao('Passo de tempo (Δt)'),
              _Opcoes<double>(
                valores: const [0.1, 0.01, 0.001],
                selecionado: controle.passo,
                rotulo: (v) => '${fmt(v, v < 0.01 ? 3 : (v < 0.1 ? 2 : 1))} s',
                cor: Paleta.azul,
                aoMudar: controle.definirPasso,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Passo menor deixa o Euler mais próximo da solução analítica.',
                  style: TextStyle(fontSize: 11.5, color: Paleta.textoSuave),
                ),
              ),
              const SizedBox(height: 16),
              const _Secao('Velocidade da animação'),
              _Opcoes<double>(
                valores: const [0.25, 0.5, 1.0, 2.0],
                selecionado: controle.velocidadeReproducao,
                rotulo: (v) => '${fmt(v, v < 1 ? 2 : 0)}×',
                cor: Paleta.violeta,
                aoMudar: controle.definirVelocidade,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: controle.alternar,
                      icon: Icon(
                        controle.tocando ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(controle.tocando ? 'Pausar' : 'Frear'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Paleta.azul,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: controle.reiniciar,
                    icon: const Icon(Icons.replay),
                    label: const Text('Reiniciar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Paleta.texto,
                      side: const BorderSide(color: Paleta.borda),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
          color: Paleta.textoSuave,
        ),
      ),
    );
  }
}

class _CartaoPista extends StatelessWidget {
  const _CartaoPista({
    required this.icone,
    required this.titulo,
    required this.cor,
    required this.selecionado,
    required this.aoToque,
  });

  final IconData icone;
  final String titulo;
  final Color cor;
  final bool selecionado;
  final VoidCallback aoToque;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: aoToque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selecionado ? cor.withAlpha(45) : Paleta.superficieAlta,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selecionado ? cor : Paleta.borda,
              width: selecionado ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icone, color: selecionado ? cor : Paleta.textoSuave),
              const SizedBox(height: 6),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selecionado ? cor : Paleta.textoSuave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controle extends StatelessWidget {
  const _Controle({
    required this.rotulo,
    required this.valor,
    required this.minimo,
    required this.maximo,
    required this.divisoes,
    required this.cor,
    required this.texto,
    required this.aoMudar,
  });

  final String rotulo;
  final double valor, minimo, maximo;
  final int divisoes;
  final Color cor;
  final String texto;
  final ValueChanged<double> aoMudar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                rotulo,
                style: const TextStyle(color: Paleta.texto, fontSize: 13),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cor.withAlpha(35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                texto,
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: cor,
            thumbColor: cor,
            inactiveTrackColor: Paleta.borda,
            overlayColor: cor.withAlpha(40),
            trackHeight: 4,
          ),
          child: Slider(
            value: valor.clamp(minimo, maximo).toDouble(),
            min: minimo,
            max: maximo,
            divisions: divisoes,
            onChanged: aoMudar,
          ),
        ),
      ],
    );
  }
}

class _Opcoes<T> extends StatelessWidget {
  const _Opcoes({
    required this.valores,
    required this.selecionado,
    required this.rotulo,
    required this.cor,
    required this.aoMudar,
  });

  final List<T> valores;
  final T selecionado;
  final String Function(T) rotulo;
  final Color cor;
  final ValueChanged<T> aoMudar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final valor in valores)
          ChoiceChip(
            label: Text(rotulo(valor)),
            selected: valor == selecionado,
            showCheckmark: false,
            onSelected: (_) => aoMudar(valor),
            selectedColor: cor.withAlpha(60),
            backgroundColor: Paleta.superficieAlta,
            side: BorderSide(color: valor == selecionado ? cor : Paleta.borda),
            labelStyle: TextStyle(
              color: valor == selecionado ? cor : Paleta.textoSuave,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
