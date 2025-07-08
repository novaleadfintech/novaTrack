import 'dart:convert';

import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/moyen_paiement_model.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/bulletin_paie/decouverte_model.dart';
import 'package:http/http.dart' as http;

import '../model/bulletin_paie/salarie_model.dart';
import '../model/request_response.dart';
import 'request_header.dart';

class DecouverteService {
  static Future<List<DecouverteModel>> getDecouvertes() async {
    List<DecouverteModel> decouvertes = [];
    var body = '''
               query Decouvertes {
    decouvertes {
        _id
        justification
        montant
        referenceTransaction
        dateEnregistrement
        montantRestant
        dureeReversement
        status
        moyenPayement{
          _id
          libelle
        }
        banque {
            _id
            name
            codeGuichet
            codeBanque
            cleRIB
            codeBIC
            numCompte
            logo
            soldeReel
            soldeTheorique
            country {
                _id
                name
                code
                tauxTVA
                phoneNumber
                initiauxPays
            }
        }
        salarie {
            _id
            dateEnregistrement
            periodPaie
            paieManner
            fullCount
            personnel {
                _id
                nom
                prenom
                email
                telephone
                adresse
                sexe
                poste{_id, libelle}
                situationMatrimoniale
                commentaire
                etat
                dateEnregistrement
                dateNaissance
                dateDebut
                dateFin
                nombreEnfant
                nombrePersonneCharge
                dureeEssai
                typePersonnel
                typeContrat
                fullCount
                pays {
                    _id
                    name
                    code
                    tauxTVA
                    phoneNumber
                    initiauxPays
                }
            }
            categoriePaie {
                _id
                categoriePaie
            }
        }
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
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['decouvertes'];
      if (data != null) {
        for (var decouverte in data) {
          decouvertes.add(DecouverteModel.fromJson(decouverte));
        }
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return decouvertes;
  }

  static Future<RequestResponse> createDecouverte({
    required String justification,
    required String salarieId,
    required String referenceTransaction,
    required double montant,
    required int dureeReversement,
    required String userId,
    required MoyenPaiementModel moyenPayement,
    required BanqueModel banque,
  }) async {
    var body = '''
    mutation CreateDecouverte {
          createDecouverte(
              justification: "$justification"
              montant: $montant
              dureeReversement: $dureeReversement,
              referenceTransaction: "$referenceTransaction",
              salarieId: "$salarieId"
              userId: "$userId"
              moyenPayement: ${moyenPayement.toJson()}
              banqueId: "${banque.id}"
      ''';
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
          return RequestResponse.response(
            message: RequestMessage.timeoutMessage,
            status: PopupStatus.serverError,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createDecouverte'];
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
        message: RequestMessage.onCatchErrorMessage,
        status: PopupStatus.serverError,
      );
    }
  }

  static Future<RequestResponse> updateDecouverte({
    required String key,
    String? justification,
    SalarieModel? salarie,
    double? montant,
    double? montantRestant,
    required MoyenPaiementModel? moyenPayement,
    required BanqueModel? banque,
    required String? referenceTransaction,
    int? dureeReversement,
  }) async {
    var body = '''
    mutation UpdateDecouverte {
          updateDecouverte(
              key: "$key"
    ''';
    if (justification != null) {
      body += 'justification: "$justification"';
    }
    if (salarie != null) {
      body += 'salarieId: "${salarie.id}"';
    }
    if (moyenPayement != null) {
      body += 'moyenPayement: ${moyenPayement.toJson()}';
    }

    if (referenceTransaction != null) {
      body += 'referenceTransaction: "$referenceTransaction",';
    }
    if (banque != null) {
      body += 'banqueId: "${banque.id}"';
    }
    if (montant != null) {
      body += 'montant: $montant';
    }
    if (montantRestant != null) {
      body += 'montantRestant: $montantRestant';
    }
    if (dureeReversement != null) {
      body += 'dureeReversement: $dureeReversement';
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
        var data = jsonData['data']['updateDecouverte'];
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
}
