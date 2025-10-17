class PayCalendarModel {
  final dynamic id;
  final String libelle;
  final DateTime dateDebut;
  final DateTime dateFin;

  PayCalendarModel({
    required this.id,
    required this.libelle,
    required this.dateDebut,
    required this.dateFin,
  });

  factory PayCalendarModel.fromJson(Map<String, dynamic> json) {
    return PayCalendarModel(
      id: json["_id"],
      libelle: json["libelle"] ?? "",
      dateDebut: DateTime.parse(json["dateDebut"]),
      dateFin: DateTime.parse(json["dateFin"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "categoriepaie": libelle,
      "dateDebut": dateDebut.toIso8601String(),
      "dateFin": dateFin.toIso8601String(),
    };
  }

  bool equalTo({required PayCalendarModel libelle}) {
    return libelle.id == id;
  }
}
