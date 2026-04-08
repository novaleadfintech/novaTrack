import "package:frontend/model/bulletin_paie/nature_rubrique.dart";

import "section_bulletin.dart";
import "tranche_model.dart";
import "type_rubrique.dart";

class RubriqueBulletin {
  final String key;
  final String rubrique;
  final String code;
  final TypeRubrique? type;
  final PorteeRubrique? portee;
  final NatureRubrique nature;
  final RubriqueRole? rubriqueRole;
  final RubriqueIdentity? rubriqueIdentity;
  final Taux? taux;
  final Bareme? bareme;
  final SectionBulletin? section;
  Calcul? sommeRubrique;
  Calcul? calcul;

  RubriqueBulletin({
    required this.key,
    required this.rubrique,
    required this.code,
    required this.type,
    required this.nature,
    required this.portee,
    this.rubriqueIdentity,
    this.rubriqueRole,
    this.calcul,
    this.taux,
    this.bareme,
    this.section,
    this.sommeRubrique,
  });

  void setCalcul({required Calcul newCalcul}) {
    calcul = newCalcul;
  }

  void setSommeRubrique({required Calcul newSommeRubrique}) {
    sommeRubrique = newSommeRubrique;
  }

  factory RubriqueBulletin.fromJson(Map<String, dynamic> json) {
    return RubriqueBulletin(
      key: json["_key"],
      rubrique: json["rubrique"],
      code: json["code"],
      type: json["type"] == null ? null : typeRubriqueFromJson(json["type"]),
      rubriqueIdentity: json["rubriqueIdentity"] != null
          ? RubriqueIdentity.identityFromJson(json["rubriqueIdentity"])
          : null,
      rubriqueRole: json["rubriqueRole"] != null
          ? RubriqueRole.rubriqueRoleFromJson(json["rubriqueRole"])
          : null,
      portee: json["portee"] == null
          ? null
          : PorteeRubrique.porteeRubriqueFromJson(json["portee"]),
      nature: natureRubriqueFromJson(json["nature"]),
      taux: json["taux"] != null ? Taux.fromJson(json["taux"]) : null,
      bareme: json["bareme"] == null ? null : Bareme.fromJson(json["bareme"]),
      section: json["section"] != null
          ? SectionBulletin.fromJson(json["section"])
          : null,
      sommeRubrique: json["sommeRubrique"] != null
          ? Calcul.fromJson(json["sommeRubrique"])
          : null,
      calcul: json["calcul"] != null ? Calcul.fromJson(json["calcul"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_key": "\"$key\"",
      "rubrique": "\"$rubrique\"",
      "code": "\"$code\"",
      "type": type == null ? null : typeRubriqueToString(type!),
      "nature": natureRubriqueToString(nature),
      "taux": taux?.toJson(),
      "portee": portee == null
          ? null
          : PorteeRubrique.porteeRubriqueToString(portee!),
      "rubriqueRole": rubriqueRole == null
          ? null
          : RubriqueRole.rubriqueRoleToString(rubriqueRole!),
      "rubriqueIdentity": rubriqueIdentity == null
          ? null
          : RubriqueIdentity.identityToString(rubriqueIdentity!),
      "section": section?.toJson(),
      "bareme": bareme?.toJson(),
      "calcul": calcul?.toJson(),
      "sommeRubrique": sommeRubrique?.toJson(),
    };
  }
}
