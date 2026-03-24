class CategorieModel {
  final String key;
  final String libelle;
  static dynamic categorieErr;

  CategorieModel({
    required this.key,
    required this.libelle,
  });

  factory CategorieModel.fromJson(Map<String, dynamic> json) {
    return CategorieModel(
      key: json["_key"],
      libelle: json["libelle"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_key": key,
      "libelle": libelle,
    };
  }
}
