// frais_divers.dart

class FraisDiversModel {
  final String libelle;
  final double montant;
  final bool tva;

  FraisDiversModel({
    required this.libelle,
    required this.montant,
    required this.tva,
  });

  factory FraisDiversModel.fromJson(Map<String, dynamic> json) {
    
    return FraisDiversModel(
      libelle: json['libelle'],
      montant: (json['montant'] as num).toDouble(),
      tva: json['tva'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'montant': montant,
      'tva': tva,
    };
  }
}
