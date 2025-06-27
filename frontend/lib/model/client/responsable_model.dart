import '../common_type.dart';

class ResponsableModel {
  final String prenom;
  final String nom;
  final Sexe sexe;
  final Civilite civilite;
  final String email;
  final int telephone;
  final String poste;

  ResponsableModel({
    required this.prenom,
    required this.nom,
    required this.sexe,
    required this.civilite,
    required this.email,
    required this.telephone,
    required this.poste,
  });

  factory ResponsableModel.fromJson(Map<String, dynamic> json) {
    return ResponsableModel(
      prenom: json["prenom"] ?? "",
      nom: json["nom"] ?? "",
      sexe: sexeFromString(json["sexe"]),
      civilite: civiliteFromString(json["civilite"]),
      email: json["email"] ?? "",
      telephone: (json["telephone"] as num?)?.toInt() ?? 0,
      poste: json["poste"] ?? "",
    );
  }

  Map<String, String> toJson() {
    return {
      "prenom": prenom,
      "nom": nom,
      "sexe": sexeToString(sexe),
      "civilite": civiliteToString(civilite),
      "email": email,
      "telephone": telephone.toString(),
      "poste": poste,
    };
  }
}
