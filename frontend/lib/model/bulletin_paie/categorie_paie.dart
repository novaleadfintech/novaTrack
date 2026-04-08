class PaieCategorieModel {
  final dynamic key;
  final String paieCategorie;

  PaieCategorieModel({
    required this.key,
    required this.paieCategorie,
  });

  factory PaieCategorieModel.fromJson(Map<String, dynamic> json) {
    return PaieCategorieModel(
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

  bool equalTo({required PaieCategorieModel paieCategorie}) {
    return paieCategorie.key == key;
  }
}
