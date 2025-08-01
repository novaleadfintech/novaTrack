import 'dart:convert';

import 'package:frontend/model/personnel/personne_prevenir.dart';
import 'package:frontend/model/personnel/poste_model.dart';

import '../model/common_type.dart';
import '../model/personnel/enum_personnel.dart';
import '../model/personnel/personnel_model.dart';
import 'package:http/http.dart' as http;

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/pays_model.dart';
import '../model/request_response.dart';
import 'request_header.dart';

class PersonnelService {
  static Future<List<PersonnelModel>> getUnarchivedPersonnels() async {
    var body = '''
              query Personnels {
                  personnels(etat: unarchived) {
                      _id
                      nom
                      prenom
                      email
                      telephone
                      pays {
                          name
                          initiauxPays
                          code
                          phoneNumber
                      }
                      dateNaissance
                    dateDebut
                    dateFin
                    dureeEssai
                    nombreEnfant
                    nombrePersonneCharge
                    typePersonnel
                    typeContrat
                    personnePrevenir {
                        nom
                        lien
                        telephone1
                        telephone2
                    }
                      adresse
                      sexe
                      poste{_id, libelle}
                      commentaire
                      etat
                      situationMatrimoniale
                      dateEnregistrement
                      fullCount
                  }
              }
            ''';
    List<PersonnelModel> personnels = [];

    var response = await http
        .post(
      Uri.parse(serverUrl),
      body: json.encode({
        'query': body,
      }),
      headers: getHeaders(),
    )
        .catchError((onError) {
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        PersonnelModel.personnelErr = RequestMessage.failgettingDataMessage;
        return PersonnelModel.personnelErr;
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['personnels'];
       if (data != null) {
        for (var personnel in data) {
          personnels.add(PersonnelModel.fromJson(personnel));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return personnels;
  }

  static Future<dynamic> getArchivedPersonnels() async {
    var body = '''
              query Personnels {
                personnels(etat: archived) {
                    _id
                    nom
                    prenom
                    email
                    pays {
                        name
                        initiauxPays
                        code
                        phoneNumber
                    }
                    telephone
                    adresse
                    sexe
                    poste{_id, libelle}
                    dateNaissance
                    dateDebut
                    dateFin
                    dureeEssai
                    nombreEnfant
                    nombrePersonneCharge
                    typePersonnel
                    typeContrat
                    personnePrevenir {
                        nom
                        lien
                        telephone1
                        telephone2
                    }
                    commentaire
                    etat
                    dateEnregistrement
                    fullCount
                    situationMatrimoniale
                }
            }

            ''';
    var response = await http
        .post(
      Uri.parse(serverUrl),
      body: json.encode({
        'query': body,
      }),
      headers: getHeaders(),
    )
        .catchError((onError) {
      PersonnelModel.personnelErr = RequestMessage.failgettingDataMessage;
      return PersonnelModel.personnelErr;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        PersonnelModel.personnelErr = RequestMessage.failgettingDataMessage;
        return PersonnelModel.personnelErr;
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['personnels'];
      List<PersonnelModel> personnels = [];
      if (data != null) {
        for (var personnel in data) {
          personnels.add(PersonnelModel.fromJson(personnel));
        }
        return personnels;
      } else {
        PersonnelModel.personnelErr = RequestMessage.failgettingDataMessage;
      }
    } else {
      PersonnelModel.personnelErr =
          jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<dynamic> getPersonnel({required String key}) async {
    var body = '''
              query Personnel {
                  personnel(key: "$key") {
                      _id
                      nom
                      prenom
                      email
                      telephone
                      adresse
                      sexe
                      pays {
                          name
                          code
                          phoneNumber
                          initiauxPays
                      }
                      poste{_id, libelle}
                      situationMatrimoniale
                      commentaire
                      etat
                      dateNaissance
                      dateDebut
                      dateFin
                      dureeEssai
                      nombreEnfant
                      nombrePersonneCharge
                      typePersonnel
                      typeContrat
                      personnePrevenir {
                          nom
                          lien
                          telephone1
                          telephone2
                      }
                      dateEnregistrement
                  }
              }

            ''';
    var response = await http
        .post(
      Uri.parse(serverUrl),
      body: json.encode({
        'query': body,
      }),
      headers: getHeaders(),
    )
        .catchError((onError) {
      PersonnelModel.personnelErr = RequestMessage.failgettingDataMessage;
      return PersonnelModel.personnelErr;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        PersonnelModel.personnelErr = RequestMessage.failgettingDataMessage;
        return PersonnelModel.personnelErr;
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['personnel'];
      if (data != null) {
        return PersonnelModel.fromJson(data);
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<RequestResponse> createPersonnel({
    required String nom,
    required String prenom,
    required String email,
    required int telephone,
    required SituationMatrimoniale situationMatrimoniale,
    required Sexe sexe,
    required PaysModel pays,
    required DateTime dateNaissance,
    required DateTime dateDebut,
    required DateTime? dateFin,
    required int nombreEnfant,
    required int nombrePersonneCharge,
    required TypePersonnel typePersonnel,
    required TypeContrat? typeContrat,
    required PersonnePrevenirModel personnePrevenir,
    required PosteModel poste,
    required String adresse,
    required int? dureeEssai,
    required String? commentaire,
  }) async {
    var body = '''
    mutation CreatePersonnel {
      createPersonnel(
          nom: "$nom"
          prenom: "$prenom"
          email: "$email"
          pays: "${pays.id}",
          telephone: $telephone
          sexe: ${sexeToString(sexe)}
          poste: "${poste.toJson()}"
          adresse: "$adresse",
          situationMatrimoniale:${situationMatrimonialeToString(situationMatrimoniale)},
          dateDebut: ${dateDebut.millisecondsSinceEpoch},
          typePersonnel: ${typePersonnelToString(typePersonnel)},
          dateNaissance: ${dateNaissance.millisecondsSinceEpoch},
          nombrePersonneCharge: $nombrePersonneCharge,
          nombreEnfant: $nombreEnfant,
          personnePrevenir: {nom: "${personnePrevenir.nom}", lien: "${personnePrevenir.lien}", telephone1: ${personnePrevenir.telephone1}, telephone2: ${personnePrevenir.telephone2}}
          ''';

    if (commentaire != null) {
      body += 'commentaire: "$commentaire",';
    }
    if (dateFin != null) {
      body += 'dateFin: ${dateFin.millisecondsSinceEpoch},';
    }
    if (dureeEssai != null) {
      body += 'dureeEssai: $dureeEssai,';
    }
    if (typeContrat != null) {
      body += 'typeContrat: ${typeContratlToString(typeContrat)},';
    }
    body += '''
      )
    }
  ''';
    var response = await http
        .post(
      Uri.parse(serverUrl),
      body: json.encode({'query': body}),
      headers: getHeaders(),
    )
        .timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        return RequestResponse.response(
          status: PopupStatus.serverError,
        );
      },
    );
    try {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createPersonnel'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.serverError,
          );
        }
      } else {
        return RequestResponse(
          message: jsonDecode(response.body)['errors'][0]['message'],
          status: PopupStatus.serverError,
        );
      }
    } catch (error) {
      return RequestResponse(
        message: error.toString(),
        status: PopupStatus.serverError,
      );
    }
  }

  static Future<RequestResponse> updatePersonnel({
    required String key,
    required String? nom,
    required String? prenom,
    required String? email,
    required int? telephone,
    required SituationMatrimoniale? situationMatrimoniale,
    required Sexe? sexe,
    required PaysModel? pays,
    required PosteModel? poste,
    required String? adresse,
    required PersonnePrevenirModel? personnePrevenir,
    required DateTime? dateNaissance,
    required DateTime? dateDebut,
    required DateTime? dateFin,
    required TypeContrat? typeContrat,
    required TypePersonnel? typePersonnel,
    required int? nombreEnfant,
    required int? nombrePersonneCharge,
    required String? commentaire,
    required int? dureeEssai,
  }) async {
    var body = '''

mutation UpdatePersonnel {
    updatePersonnel(
        key: "$key",
 ''';
    if (nom != null) {
      body += 'nom: "$nom",';
    }
    if (prenom != null) {
      body += 'prenom: "$prenom",';
    }
    if (email != null) {
      body += 'email: "$email",';
    }
    if (poste != null) {
      body += 'poste: ${poste.toJson()},';
    }
    if (telephone != null) {
      body += 'telephone: $telephone,';
    }
    if (adresse != null) {
      body += 'adresse: "$adresse",';
    }
    if (pays != null) {
      body += 'pays: "${pays.id}"';
    }
    if (situationMatrimoniale != null) {
      body +=
          'situationMatrimoniale:${situationMatrimonialeToString(situationMatrimoniale)},';
    }
    if (sexe != null) {
      body += 'sexe: ${sexeToString(sexe)},';
    }
    if (commentaire != null) {
      body += 'commentaire: "$commentaire",';
    }
    if (dateFin != null) {
      body += 'dateFin: ${dateFin.millisecondsSinceEpoch},';
    }
    if (typeContrat != null) {
      body += 'typeContrat: ${typeContratlToString(typeContrat)},';
    }
    if (typePersonnel != null) {
      body += 'typePersonnel: ${typePersonnelToString(typePersonnel)},';
    }
    if (dateNaissance != null) {
      body += 'dateNaissance: ${dateNaissance.millisecondsSinceEpoch},';
    }
    if (dateDebut != null) {
      body += 'dateDebut: ${dateDebut.millisecondsSinceEpoch},';
    }
    if (nombreEnfant != null) {
      body += 'nombreEnfant: $nombreEnfant,';
    }
    if (dureeEssai != null) {
      body += 'dureeEssai: $dureeEssai,';
    }
    if (nombrePersonneCharge != null) {
      body += 'nombrePersonneCharge: $nombrePersonneCharge,';
    }
    if (personnePrevenir != null) {
      body +=
          'personnePrevenir: {nom: "${personnePrevenir.nom}", lien: "${personnePrevenir.lien}", telephone1: ${personnePrevenir.telephone1}, telephone2: ${personnePrevenir.telephone2}},';
    }
    body += '''
      )
    }
  ''';

 
    try {
      var response = await http
          .post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      )
          .timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          throw RequestMessage.timeoutMessage;
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updatePersonnel'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.serverError,
          );
        }
      } else {
        return RequestResponse(
          message: jsonDecode(response.body)['errors'][0]['message'],
          status: PopupStatus.serverError,
        );
      }
    } catch (error) {
      return RequestResponse(
        message: error.toString(),
        status: PopupStatus.serverError,
      );
    }
  }

  static Future<RequestResponse> archivedPersonnel({
    required String personnelId,
  }) async {
    var body = '''
    mutation ArchivedPersonnel {
      archivedPersonnel(key: "$personnelId")
    }
  ''';

    try {
      var response = await http
          .post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      )
          .timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          throw RequestMessage.timeoutMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['archivedPersonnel'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: jsonDecode(response.body)['errors'][0]['message'],
            status: PopupStatus.serverError,
          );
        }
      } else {
        return RequestResponse(
          message: RequestMessage.serverErrorMessage,
          status: PopupStatus.serverError,
        );
      }
    } catch (error) {
      return RequestResponse(
        message: RequestMessage.onCatchErrorMessage,
        status: PopupStatus.serverError,
      );
    }
  }

  static Future<RequestResponse> unArchivedPersonnel({
    required String personnelId,
  }) async {
    var body = '''
    mutation UnarchivedPersonnel {
      unarchivedPersonnel(key: "$personnelId")
    }
  ''';

    try {
      var response = await http
          .post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      )
          .timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          throw RequestMessage.timeoutMessage;
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['unarchivedPersonnel'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: jsonDecode(response.body)['errors'][0]['message'],
            status: PopupStatus.serverError,
          );
        }
      } else {
        return RequestResponse(
          message: RequestMessage.serverErrorMessage,
          status: PopupStatus.serverError,
        );
      }
    } catch (error) {
      return RequestResponse(
        message: RequestMessage.onCatchErrorMessage,
        status: PopupStatus.serverError,
      );
    }
  }
}
