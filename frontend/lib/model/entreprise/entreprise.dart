import 'package:frontend/model/pays_model.dart';

class Entreprise {
  final String? id;
  final String? raisonSociale;
  final String? logo;
  final String? adresse;
  final String? email;
  final String? ville;
  final int? telephone;
  final String? tamponSignature;
  final String? nomDG;
  final PaysModel? pays;

  Entreprise({
    required this.id,
    required this.raisonSociale,
    required this.logo,
    required this.adresse,
    required this.email,
    required this.telephone,
    required this.tamponSignature,
    required this.nomDG,
    required this.ville,
    required this.pays,
  });

  // Convertir l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'raisonSociale': raisonSociale,
      'logo': logo,
      'adresse': adresse,
      'email': email,
      'telephone': telephone,
      'tamponSignature': tamponSignature,
      'ville': ville,
      'nomDG': nomDG,
      "pays": pays?.toJson(),
    };
  }

  factory Entreprise.fromJson(Map<String, dynamic> json) {
    return Entreprise(
        id: json["_id"],
        raisonSociale: json['raisonSociale'],
      logo: json['logo'],
      adresse: json['adresse'],
      email: json['email'],
      telephone: json['telephone'],
        ville: json['ville'],
      tamponSignature: json['tamponSignature'],
      nomDG: json['nomDG'],
        pays: json['pays'] != null ? PaysModel.fromJson(json['pays']) : null
    );
  }
}

class StrictEntreprise {
  final String id;
  final String raisonSociale;
  final String logo;
  final String adresse;
  final String email;
  final int telephone;
  final String tamponSignature;
  final String nomDG;
  final String ville;
  final PaysModel pays;

  StrictEntreprise({
    required this.id,
    required this.raisonSociale,
    required this.logo,
    required this.adresse,
    required this.email,
    required this.telephone,
    required this.tamponSignature,
    required this.nomDG,
    required this.pays,
    required this.ville,
  });

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'raisonSociale': raisonSociale,
      'logo': logo,
      'adresse': adresse,
      'email': email,
      'telephone': telephone,
      'tamponSignature': tamponSignature,
      'nomDG': nomDG,
      'ville': ville,
      'pays': pays.toJson(), 
    };
  }

  factory StrictEntreprise.fromJson(Map<String, dynamic> json) {
    return StrictEntreprise(
      id: json["_id"],
      raisonSociale: json['raisonSociale'],
      logo: json['logo'],
      adresse: json['adresse'],
      ville: json['ville'],
      email: json['email'],
      telephone: int.parse(json['telephone'].toString()),
      tamponSignature: json['tamponSignature'],
      nomDG: json['nomDG'],
      pays: PaysModel.fromJson(json['pays']),
    );
  }
}
