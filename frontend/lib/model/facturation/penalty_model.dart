// frais_divers.dart

class PenaltyModel {
  final double montant;
  final int nombreRetard;
  final bool isPaid;

  PenaltyModel({
    required this.isPaid,
    required this.montant,
    required this.nombreRetard,
  });

  factory PenaltyModel.fromJson(Map<String, dynamic> json) {
    return PenaltyModel(
      isPaid: json['isPaid'],
      montant: (json['montant'] as num).toDouble(),
      nombreRetard: (json['nombreRetard'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPaid': isPaid,
      'montant': montant,
      'nombreRetard': nombreRetard,
    };
  }
}
