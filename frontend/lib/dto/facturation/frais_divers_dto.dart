// frais_divers.dart

class FraisDiversDto {
  final String libelle;
  final double montant;
  final bool tva;

  FraisDiversDto({
    required this.libelle,
    required this.montant,
    required this.tva,
  });

  factory FraisDiversDto.fromJson(Map<String, dynamic> json) {
    return FraisDiversDto(
      libelle: json['libelle'],
      montant: (json['montant'] as num).toDouble(),
      tva: json['tva'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': "\"$libelle\"",
      'montant': montant,
      'tva': tva,
    };
  }
}
