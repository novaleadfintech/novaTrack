class PaysModel {
  final String? key;
  final int code;
  final String name;
  final List<int> initiauxPays;
  final double? tauxTVA;
  final int? phoneNumber;

  PaysModel({
    this.key,
    required this.name,
    required this.code,
    required this.initiauxPays,
    this.phoneNumber,
    this.tauxTVA,
  });

  factory PaysModel.fromJson(Map<String, dynamic> json) {
    return PaysModel(
      code: json["code"],
      key: json["_key"] ?? "",
      name: json["name"] ?? "",
      initiauxPays: json["initiauxPays"] == null
          ? []
          : List<int>.from(json["initiauxPays"].map((x) => x)),
      phoneNumber: json["phoneNumber"] ?? 1,
      tauxTVA:
          json["tauxTVA"] == null ? 0 : (json["tauxTVA"] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "_key": "\"$key\"",
      "initiauxPays": initiauxPays,
      "tauxTVA": tauxTVA,
      "phoneNumber": phoneNumber,
      "name": "\"${name.toString()}\"",
    };
  }

  
}
