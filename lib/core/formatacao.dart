/// Formata um número com vírgula decimal (padrão brasileiro).
String fmt(double valor, [int casas = 2]) =>
    valor.toStringAsFixed(casas).replaceAll('.', ',');
