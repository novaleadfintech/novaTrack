class PersonnePrevenirModel {
  final String nom;
  final String lien;
  final int telephone1;
  final int? telephone2;

  PersonnePrevenirModel({
    required this.nom,
    required this.lien,
    required this.telephone1,
    required this.telephone2,
  });

  factory PersonnePrevenirModel.fromJson(Map<String, dynamic> json) {
    return PersonnePrevenirModel(
      nom: json['nom'],
      lien: json['lien'],
      telephone1: (json['telephone1'] as num).toInt(),
      telephone2: json['telephone2'] != null
          ? (json['telephone2'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'lien': lien,
      'telephone1': telephone1,
      'telephone2': telephone2,
    };
  }
}
