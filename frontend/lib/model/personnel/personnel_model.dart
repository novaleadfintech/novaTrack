import 'package:frontend/model/personnel/poste_model.dart';

import '../../helper/string_helper.dart';
import '../pays_model.dart';
import '../common_type.dart';
import 'enum_personnel.dart';
import 'personne_prevenir.dart';

class PersonnelModel {
  final String id;
  final String nom;
  final String prenom;
  final String? email;
  final int? telephone;
  final PaysModel? pays;
  final String? adresse;
  final Sexe? sexe;
  final PosteModel? poste;
  final SituationMatrimoniale? situationMatrimoniale;
  final String? commentaire;
  final EtatPersonnel? etat;
  final DateTime? dateEnregistrement;
  final DateTime? dateNaissance;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final int? nombreEnfant;
  final int? dureeEssai;
  final int? nombrePersonneCharge;
  final TypePersonnel? typePersonnel;
  final TypeContrat? typeContrat;
  final PersonnePrevenirModel? personnePrevenir;
  final int? fullCount;

  static dynamic personnelErr;

  PersonnelModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.pays,
    this.telephone,
    this.adresse,
    this.sexe,
    this.poste,
    this.dateDebut,
    this.dateFin,
    this.dateNaissance,
    this.personnePrevenir,
    this.typeContrat,
    this.typePersonnel,
    this.nombreEnfant,
    this.nombrePersonneCharge,
    this.situationMatrimoniale,
    this.commentaire,
    this.etat,
    this.dureeEssai,
    this.dateEnregistrement,
    this.fullCount,
  });

  factory PersonnelModel.fromJson(Map<String, dynamic> json) {
    return PersonnelModel(
      id: json['_id'] ?? "",
      nom: json['nom'] ?? "",
      prenom: json['prenom'] ?? "",
      email: json['email'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      sexe: json['sexe'] != null ? sexeFromString(json['sexe']) : null,
      poste: json['poste'] != null ? PosteModel.fromJson(json['poste']) : null,
      pays: json['pays'] != null ? PaysModel.fromJson(json['pays']) : null,
      situationMatrimoniale: json['situationMatrimoniale'] != null
          ? situationMatrimonialeFromString(json['situationMatrimoniale'])
          : null,
      commentaire: json['commentaire'],
      etat: json['etat'] != null ? etatPersonnelFromString(json['etat']) : null,
      dateEnregistrement: json['dateEnregistrement'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateEnregistrement'])
          : null,
      dateNaissance: json['dateNaissance'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateNaissance'])
          : null,
      dateDebut: json['dateDebut'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateDebut'])
          : null,
      dateFin: json['dateFin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateFin'])
          : null,
      dureeEssai: json['dureeEssai'] ?? 0,
      nombreEnfant: json['nombreEnfant'],
      nombrePersonneCharge: json['nombrePersonneCharge'],
      personnePrevenir: json['personnePrevenir'] != null
          ? PersonnePrevenirModel.fromJson(json['personnePrevenir'])
          : null,
      typePersonnel: json['typePersonnel'] != null
          ? typePersonnelFromString(json['typePersonnel'])
          : null,
      typeContrat: json['typeContrat'] != null
          ? typeContratFromString(json['typeContrat'])
          : null,
      fullCount: json['fullCount'],
    );
  }

  /// Méthode pour convertir une instance en JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'sexe': sexe != null ? sexeToString(sexe!) : null,
      'poste': poste?.toJson(),
      'pays': pays?.toJson(),
      'situationMatrimoniale': situationMatrimoniale != null
          ? situationMatrimonialeToString(situationMatrimoniale!)
          : null,
      'commentaire': commentaire,
      'etat': etat != null ? etatPersonnelToString(etat!) : null,
      'dateEnregistrement': dateEnregistrement?.millisecondsSinceEpoch,
      'dateNaissance': dateNaissance?.millisecondsSinceEpoch,
      'dateDebut': dateDebut?.millisecondsSinceEpoch,
      'dateFin': dateFin?.millisecondsSinceEpoch,
      'nombreEnfant': nombreEnfant,
      'nombrePersonneCharge': nombrePersonneCharge,
      'personnePrevenir': personnePrevenir?.toJson(),
      'dureeEssai': dureeEssai,
      'typePersonnel':
          typePersonnel != null ? typePersonnelToString(typePersonnel!) : null,
      'typeContrat':
          typeContrat != null ? typeContratlToString(typeContrat!) : null,
      'fullCount': fullCount,
    };
  }

  String toStringify() {
    return "${nom.toUpperCase()} ${capitalizeFirstLetter(word: prenom)}";
  }

   bool equalTo({required PersonnelModel personnel}) {
    return personnel.id == id;
  }
}
