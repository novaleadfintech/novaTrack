import './flux_financier_model.dart';

class   YearsBilan {
  final int mois;
  final double input;
  final double output;

  YearsBilan({
    required this.mois,
    required this.input,
    required this.output,
  });

  // Factory method pour convertir le JSON en modèle Bilan
  factory YearsBilan.fromJson(Map<String, dynamic> json) {

    return YearsBilan(
      mois: json['mois'],
      input: json['input'].toDouble(),
      output: json['output'].toDouble(),
    );
  }

  // Méthode toJson pour convertir Bilan en JSON
  Map<String, dynamic> toJson() {
    return {
      'mois': mois,
      'input': input,
      'output': output,
    };
  }
}


class Bilan {
  final List<FluxFinancierModel> fluxFinanciers;
  final double total;
  final double input;
  final double output;

  Bilan({
    required this.fluxFinanciers,
    required this.total,
    required this.input,
    required this.output,
  });

  // Factory method pour convertir le JSON en modèle Bilan
  factory Bilan.fromJson(Map<String, dynamic> json) {
    List fluxFromJson = json['fluxFinanciers'];

    List<FluxFinancierModel> fluxList =
        fluxFromJson.map((flux) => FluxFinancierModel.fromJson(flux)).toList();
    return Bilan(
      fluxFinanciers: fluxList,
      total: json['total'].toDouble(),
      input: json['input'].toDouble(),
      output: json['output'].toDouble(),
    );
  }

  // Méthode toJson pour convertir Bilan en JSON
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> fluxToJson =
        fluxFinanciers.map((flux) => flux.toJson()).toList();

    return {
      'fluxFinanciers': fluxToJson,
      'total': total,
      'input': input,
      'output': output,
    };
  }
}
