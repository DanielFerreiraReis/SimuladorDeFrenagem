/// Tipos de pista disponíveis na tela.
enum Pista { seca, gelo, personalizada }

/// Coeficientes de atrito de cada pista (valores do trabalho, Etapa 2).
class PerfilPista {
  const PerfilPista(this.nome, this.coefEstatico, this.coefCinetico);
  final String nome;
  final double coefEstatico, coefCinetico;
}

const Map<Pista, PerfilPista> perfis = {
  Pista.seca: PerfilPista('Pista seca', 1.0, 0.8),
  Pista.gelo: PerfilPista('Gelo', 0.15, 0.1),
};
