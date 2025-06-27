// client_moral.dart
import 'package:frontend/model/client/responsable_model.dart';

import '../pays_model.dart';
import '../client/client_model.dart';
import 'categorie_model.dart';
import './enum_client.dart';

class ClientMoralModel extends ClientModel {
  final dynamic raisonSociale;
  final String? logo;
  final ResponsableModel? responsable;
  final CategorieModel? categorie;

  ClientMoralModel({
    super.id,
    super.email,
    super.telephone,
    super.nature,
    super.adresse,
    super.pays,
    super.etat,
    super.dateEnregistrement,
    super.typeName,
    super.fullCount,
    required this.raisonSociale,
     this.logo,
    this.responsable,
    this.categorie,
  });

  factory ClientMoralModel.fromJson(Map<String, dynamic> json) {
    return ClientMoralModel(
      id: json['_id'] ?? '',
      email: json['email'],
      telephone: (json["telephone"] as num?)?.toInt(),
      adresse: json['adresse'],
      pays: json['pays'] != null ? PaysModel.fromJson(json['pays']) : null,
      etat: json['etat'] != null ? etatClientFromString(json['etat']) : null,
      nature: json['nature'] != null ? natureClientFromString(json['nature']) : null,
      dateEnregistrement: json['dateEnregistrement'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateEnregistrement'])
          : null,
      fullCount: json['fullCount'],
      typeName: TypeClient.moral,
      raisonSociale: json['raisonSociale'] ?? '',
      logo: json['logo'],
      responsable: json['responsable'] != null ? ResponsableModel.fromJson(json['responsable']) : null,
      categorie: json['categorie'] != null ? CategorieModel.fromJson(json['categorie']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'pays': pays?.toJson(),
      'etat': etatClientToString(etat!),
      '__typeName': typeClientToString(typeName!),
      'dateEnregistrement': dateEnregistrement?.millisecondsSinceEpoch,
      'nature': natureClientToString(nature!),
      'fullCount': fullCount,
      'raisonSociale': raisonSociale,
      'logo': logo,
      'responsable': responsable?.toJson(),
      'categorie': categorie?.toJson(),
    };
  }
}
