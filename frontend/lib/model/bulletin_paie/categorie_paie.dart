class paieCategorieModel {
  final dynamic key;
  final String paieCategorie;

  paieCategorieModel({
    required this.key,
    required this.paieCategorie,
  });

  factory paieCategorieModel.fromJson(Map<String, dynamic> json) {
    return paieCategorieModel(
      key: json["_key"],
      paieCategorie: json["paieCategorie"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_key": key,
      "paieCategorie": paieCategorie,
    };
  }

  bool equalTo({required paieCategorieModel paieCategorie}) {
    return paieCategorie.key == key;
  }
}
