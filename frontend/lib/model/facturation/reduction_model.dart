class ReductionModel {
  final double valeur;
  final String? unite;

  ReductionModel({
    required this.valeur,
    required this.unite,
  });

  factory ReductionModel.fromJson(Map<String, dynamic> json) {
    return ReductionModel(
      unite: json["unite"],
      valeur: json["valeur"] != null ? (json["valeur"] as num).toDouble() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"valeur": valeur, "unite": unite};
  }
}
