import 'package:frontend/helper/string_helper.dart';
import '../pays_model.dart';
import './client_moral_model.dart';
import './client_physique_model.dart';
import './enum_client.dart';

class ClientModel {
  final dynamic id;
  final dynamic email;
  final int? telephone;
  final dynamic adresse;
  final PaysModel? pays;
  final EtatClient? etat;
  final NatureClient? nature;
  final DateTime? dateEnregistrement;
  final int? fullCount;
  final TypeClient? typeName;
  static dynamic clientErr;

  ClientModel({
    required this.id,
    this.typeName,
    this.email,
    this.nature,
    this.telephone,
    this.adresse,
    this.pays,
    this.etat,
    this.dateEnregistrement,
    this.fullCount,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('raisonSociale')) {
      return ClientMoralModel.fromJson(json);
    } else if (json.containsKey('nom')) {
      return ClientPhysiqueModel.fromJson(json);
    } else {
      return ClientModel(
        id: json['_id'],
        email: json['email'],
        telephone: json['telephone'],
        adresse: json['adresse'],
        pays: json['pays'] != null ? PaysModel.fromJson(json['pays']) : null,
        etat: json['etat'] != null ? etatClientFromString(json['etat']) : null,
        nature: json['nature'] != null ? natureClientFromString(json['nature']) : null,
        dateEnregistrement: json['dateEnregistrement'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['dateEnregistrement'])
            : null,
        fullCount: json['fullCount']?.toInt(),
        typeName: json['__typeName'] != null ? typeClientFromString(json['__typeName']) : null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'nature': natureClientToString(nature!),
      'pays': pays?.toJson(),
      'etat': etatClientToString(etat!),
      '__typeName': typeName,
      'dateEnregistrement': dateEnregistrement?.millisecondsSinceEpoch,
      'fullCount': fullCount,
    };
  }

  String toStringify() {
    if (this is ClientMoralModel) {
      return (this as ClientMoralModel).raisonSociale;
    }
    return "${(this as ClientPhysiqueModel).nom.toUpperCase()} ${capitalizeFirstLetter(word: (this as ClientPhysiqueModel).prenom)}";
  }
  bool equalTo({required ClientModel? client}) {
    if (client == null) return false;
    return client.id == id;
  }
}
