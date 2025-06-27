class OldPenaltyModel {
  final String libelle;
  final double montant;
  final int nbreRetard;

  OldPenaltyModel({
    required this.libelle,
    required this.montant,
    required this.nbreRetard,
  });

  factory OldPenaltyModel.fromJson(Map<String, dynamic> json) {
    return OldPenaltyModel(
      libelle: json['libelle'],
      montant: (json['montant'] as num).toDouble(),
      nbreRetard: (json['nbreRetard'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'montant': montant,
      'nbreRetard': nbreRetard,
    };
  }
}
