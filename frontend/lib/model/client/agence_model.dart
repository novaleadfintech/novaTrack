class AgenceModel {
  final String nom;
  AgenceModel({
    required this.nom,
  });

  factory AgenceModel.fromJson(Map<String, dynamic> json) {
    return AgenceModel(
      nom: json['nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
    };
  }
}
