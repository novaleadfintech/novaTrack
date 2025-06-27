class ProfilModel {
  final String id;
  final String libelle;

  ProfilModel({
    required this.libelle,
    required this.id,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      id: json['_id'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "libelle": libelle,
      '_id': id,
    };
  }
}
