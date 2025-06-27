import '../pays_model.dart';
import './enum_client.dart';
import './client_model.dart';
import '../common_type.dart';

class ClientPhysiqueModel extends ClientModel {
  final String nom;
  final dynamic prenom;
  final Sexe? sexe;

  ClientPhysiqueModel({
    required super.id,
    super.email,
    super.telephone,
    super.adresse,
    super.pays,
    super.etat,
    super.nature,
    super.typeName,
    super.dateEnregistrement,
    super.fullCount,
    required this.nom,
    required this.prenom,
    this.sexe,
  });

  factory ClientPhysiqueModel.fromJson(Map<String, dynamic> json) {
    return ClientPhysiqueModel(
      id: json['_id'] ?? '',
      email: json['email'],
      telephone: (json["telephone"] as num?)?.toInt(),
      adresse: json['adresse'],
      pays: json['pays'] != null ? PaysModel.fromJson(json['pays']) : null,
      etat: json['etat'] != null ? etatClientFromString(json['etat']) : null,
      nature: json['nature'] != null
          ? natureClientFromString(json['nature'])
          : null,
      dateEnregistrement: json['dateEnregistrement'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateEnregistrement'])
          : null,
      fullCount: json['fullCount'],
      typeName: TypeClient.physique,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      sexe: json['sexe'] != null ? sexeFromString(json['sexe']) : null,
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
      //'agences': agences?.map((agence) => agence.toJson()).toList(),
      'fullCount': fullCount,
      'nom': nom,
      'prenom': prenom,
      'sexe': sexeToString(sexe!),
    };
  }
}
