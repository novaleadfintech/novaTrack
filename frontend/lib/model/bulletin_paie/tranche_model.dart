import 'package:frontend/model/bulletin_paie/rubrique.dart';

enum TrancheValueType {
  taux("Taux"),
  valeur("Valeur");

  final String label;
  const TrancheValueType(this.label);
}

String trancheValueTypeToString(TrancheValueType type) {
  return type.toString().split('.').last;
}

TrancheValueType trancheValueTypeFromJson(String value) {
  return TrancheValueType.values
      .firstWhere((e) => e.toString().split('.').last == value);
}

enum RubriqueIdentity {
  anciennete("Ancienneté"),
  avanceSurSalaire("Avance sur salaire"),
  primeExceptionnellz("Prime exeptionnelle"),
  nombrePersonneCharge("Nombre de personnes à charge"),
  netPayer("Net à payer");

  final String label;
  const RubriqueIdentity(this.label);
}

String constantIdentityToString(RubriqueIdentity identity) {
  return identity.toString().split('.').last;
}

RubriqueIdentity constantIdentityFromJson(String identity) {
  return RubriqueIdentity.values
      .firstWhere((e) => e.toString().split('.').last == identity);
}
enum RubriqueRole {
  rubrique("Rubrique"),
  variable("Variable de paie");

  final String label;
  const RubriqueRole(this.label);
}

String rubriqueRoleToString(RubriqueRole rubriqueRole) {
  return rubriqueRole.toString().split('.').last;
}

RubriqueRole rubriqueRoleFromJson(String rubriqueRole) {
  return RubriqueRole.values
      .firstWhere((e) => e.toString().split('.').last == rubriqueRole);
}

enum PaieManner {
  finMois("Paiement à la fin du mois"),
  termeEchu("Paiement à terme échu"),
  finPeriod("Paiement à la fin de la période");

  final String label;
  const PaieManner(this.label);
}

String paieMannerToString(PaieManner paieManner) {
  return paieManner.toString().split('.').last;
}

PaieManner paieMannerFromJson(String paieManner) {
  return PaieManner.values
      .firstWhere((e) => e.toString().split('.').last == paieManner);
}

enum TypePaie {
  taux("Taux"),
  forfait("Forfait");

  final String label;
  const TypePaie(this.label);
}

String typePaieToString(TypePaie type) {
  return type.toString().split('.').last;
}

TypePaie typePaieFromJson(String value) {
  return TypePaie.values
      .firstWhere((e) => e.toString().split('.').last == value);
}

enum BaseType {
  valeur("Valeur"),
  rubrique("Rubrique");

  final String label;
  const BaseType(this.label);
}

String baseTypeToString(BaseType type) {
  return type.toString().split('.').last;
}

BaseType baseTypeFromJson(String value) {
  return BaseType.values
      .firstWhere((e) => e.toString().split('.').last == value);
}

enum Operateur {
  multiplication("Multiplication"),
  addition("Addition"),
  soustraction("Soustration"),
  division("Division");

  final String label;
  const Operateur(this.label);
}

String operateurToString(Operateur operateur) {
  return operateur.toString().split('.').last;
}

Operateur operateurFromJson(String operateur) {
  return Operateur.values
      .firstWhere((e) => e.toString().split('.').last == operateur);
}

// Taux
class Taux {
  final RubriqueBulletin base;
  final double taux;

  Taux({required this.base, required this.taux});

  factory Taux.fromJson(Map<String, dynamic> json) => Taux(
      base: RubriqueBulletin.fromJson(json['base']),
      taux: json['taux'].toDouble());

  Map<String, dynamic> toJson() => {
        "base": "\"${base.code}\"",
        "taux": taux,
      };
}

class TrancheValue {
  final TrancheValueType type;
  final Taux? taux;
  final double? valeur;

  TrancheValue({
    required this.type,
    this.taux,
    this.valeur,
  });

  factory TrancheValue.fromJson(Map<String, dynamic> json) => TrancheValue(
        type: trancheValueTypeFromJson(json['type']),
        taux: json['taux'] != null ? Taux.fromJson(json['taux']) : null,
        valeur: json['valeur']?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'type': trancheValueTypeToString(type),
        'taux': taux?.toJson(),
        'valeur': valeur,
      };
}

// Tranche
class Tranche {
  final int min;
  final int? max;
  final TrancheValue value;

  Tranche({
    required this.min,
    required this.max,
    required this.value,
  });

  factory Tranche.fromJson(Map<String, dynamic> json) => Tranche(
        min: json['min'],
        max: json['max'],
        value: TrancheValue.fromJson(json['value']),
      );

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'value': value.toJson(),
      };
}

// Bareme
class Bareme {
  final RubriqueBulletin reference;
  final List<Tranche> tranches;

  Bareme({
    required this.reference,
    required this.tranches,
  });

  factory Bareme.fromJson(Map<String, dynamic> json) => Bareme(
        reference: RubriqueBulletin.fromJson(json["reference"]),
        tranches: List<Tranche>.from(
          json['tranches'].map((t) => Tranche.fromJson(t)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "reference": "\"${reference.code}\"",
        'tranches': tranches.map((t) => t.toJson()).toList(),
      };
}

// ElementCalcul
class ElementCalcul {
  final BaseType type;
  final double? valeur;
  final RubriqueBulletin? rubrique;

  ElementCalcul({
    required this.type,
    this.valeur,
    this.rubrique,
  });

  factory ElementCalcul.fromJson(Map<String, dynamic> json) {
    return ElementCalcul(
      type: baseTypeFromJson(json['type']),
      valeur: json['valeur']?.toDouble(),
      rubrique: json['rubrique'] != null
          ? RubriqueBulletin.fromJson(json['rubrique'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': baseTypeToString(type),
        'valeur': valeur,
        'rubrique': type == BaseType.rubrique ? "\"${rubrique?.code}\"" : null,
      };
}

// Calcul
class Calcul {
  final Operateur operateur;
  final List<ElementCalcul> elements;

  Calcul({
    required this.operateur,
    required this.elements,
  });

  factory Calcul.fromJson(Map<String, dynamic> json) {
    return Calcul(
      operateur: operateurFromJson(json['operateur']),
      elements: List<ElementCalcul>.from(
        json['elements'].map((e) => ElementCalcul.fromJson(e)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'operateur': operateurToString(operateur),
        'elements': elements.map((e) => e.toJson()).toList(),
      };
}
