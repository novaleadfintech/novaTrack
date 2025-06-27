import 'package:frontend/model/bulletin_paie/salarie_model.dart';
import 'package:frontend/model/bulletin_paie/validate_bulletin_model.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/moyen_paiement_model.dart';

import 'etat_bulletin.dart';
import 'rubrique_paie.dart';

class BulletinPaieModel {
  final String id;
  final EtatBulletin etat;
  final MoyenPaiementModel? moyenPayement;
  final String? referencePaie;
  final DateTime debutPeriodePaie;
  final DateTime finPeriodePaie;
  final BanqueModel? banque;
  final DateTime dateEdition;
  final DateTime? datePayement;
  final SalarieModel salarie;
  final List<RubriqueOnBulletinModel> rubriques;
  final List<ValidateBulletinModel>? validated;


  BulletinPaieModel({
    required this.id,
    required this.etat,
    this.moyenPayement,
    required this.referencePaie,
    required this.debutPeriodePaie,
    required this.finPeriodePaie,
    this.banque,
    this.datePayement,
    required this.validated,
    required this.dateEdition,
    required this.salarie,
    required this.rubriques,
  });

  factory BulletinPaieModel.fromJson(Map<String, dynamic> json) {
    return BulletinPaieModel(
      id: json['_id'],
      etat: etatBulletinFromJson(json['etat']),
moyenPayement: json['moyenPayement'] != null
          ? MoyenPaiementModel.fromJson(json["moyenPayement"])
          : null,
          
      debutPeriodePaie:
          DateTime.fromMillisecondsSinceEpoch(json['debutPeriodePaie']),
      finPeriodePaie:
          DateTime.fromMillisecondsSinceEpoch(json['finPeriodePaie']),
      referencePaie: json['referencePaie'],
      banque:
          json['banque'] != null ? BanqueModel.fromJson(json['banque']) : null,
      dateEdition: DateTime.fromMillisecondsSinceEpoch(json['dateEdition']),
      datePayement: json['datePayement'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['datePayement'])
          : null,
      salarie: SalarieModel.fromJson(json['salarie']),
      rubriques: (json['rubriques'] as List<dynamic>)
          .map((e) => RubriqueOnBulletinModel.fromJson(e))
          .toList(),
      validated: json["validate"] != null
          ? (json["validate"] as List<dynamic>)
              .map((e) => ValidateBulletinModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'etat': etatBulletinToString(etat),
      'moyenPayement': moyenPayement?.toJson(),
      'debutPeriodePaie': debutPeriodePaie,
      'finPeriodePaie': finPeriodePaie,
      'referencePaie': referencePaie, 
      'banque': banque?.toJson(),
      'datePayement': datePayement?.millisecondsSinceEpoch,
      'dateEdition': dateEdition,
      "validate": validated?.map((e) => e.toJson()).toList(),
      'salarie': salarie.toJson(),
      'rubriques': rubriques.map((e) => e.toJson()).toList(),
    };
  }
}
