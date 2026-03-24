class ProfilModel {
  final String key;
  final String libelle;

  ProfilModel({
    required this.libelle,
    required this.key,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      key: json['_key'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "libelle": libelle,
      '_key': key,
    };
  }
}
