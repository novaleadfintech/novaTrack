class ServiceTarifModel {
  final int minQuantity;
  final double prix;
  final int? maxQuantity;

  ServiceTarifModel({
    required this.minQuantity,
    required this.prix,
    this.maxQuantity,
  });

  factory ServiceTarifModel.fromJson(Map<String, dynamic> json) {
    return ServiceTarifModel(
      minQuantity: (json['minQuantity'] as num?)?.toInt() ?? 0,
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      maxQuantity: json['maxQuantity'] != null
          ? (json['maxQuantity'] as num?)?.toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minQuantity': minQuantity,
      'prix': prix,
      'maxQuantity': maxQuantity,
    };
  }
}
