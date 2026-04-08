class PayCalendarModel {
  final dynamic key;
  final String libelle;
  final DateTime dateDebut;
  final DateTime dateFin;
  final EtatPayCalendar? etat;

  PayCalendarModel({
    required this.key,
    required this.libelle,
    required this.dateDebut,
    required this.dateFin,
    this.etat,
  });

  factory PayCalendarModel.fromJson(Map<String, dynamic> json) {
    return PayCalendarModel(
      key: json["_key"],
      libelle: json["libelle"] ?? "",
      dateDebut: DateTime.fromMillisecondsSinceEpoch(json["dateDebut"]),
      dateFin: DateTime.fromMillisecondsSinceEpoch(json["dateFin"]),
      etat: json["etat"] == null
          ? EtatPayCalendar.tobeOpen
          : etatPayCalendarFromJson(json["etat"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_key": key,
      "paieCategorie": libelle,
      "dateDebut": dateDebut.toIso8601String(),
      "dateFin": dateFin.toIso8601String(),
    };
  }

  bool equalTo({required PayCalendarModel libelle}) {
    return libelle.key == key;
  }
}

enum EtatPayCalendar {
  opened("Ouvert"),
  closed("fermé"),
  tobeOpen("à ouvrir");

  final String label;
  const EtatPayCalendar(this.label);
}

String etatPayCalendarToString(EtatPayCalendar etat) {
  return etat.toString().split(".").last;
}

EtatPayCalendar etatPayCalendarFromJson(String etat) {
  return EtatPayCalendar.values
      .firstWhere((e) => e.toString().split(".").last == etat);
}
