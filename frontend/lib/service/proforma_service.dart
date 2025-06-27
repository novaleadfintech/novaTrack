import 'dart:convert';
import 'package:frontend/dto/facturation/ligne_dto.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/entreprise/banque.dart';
import '../model/facturation/enum_facture.dart';
import '../model/facturation/facture_acompte.dart';
import '../model/facturation/proforma_model.dart';
import '../model/facturation/reduction_model.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';
// import '../model/facturation/frais_divers_model.dart';

class ProformaService {
  static Future<List<ProformaModel>> getProformas() async {
    var body = '''
                query Proformas {
                  proformas {
                    _id
                    reference
                    reduction{
                      valeur
                      unite
                    }
                    tva
                    tauxTVA
                    dateEnregistrement
                    status
                    montant
                    dateEtablissementProforma
                    garantyTime
                    dateEnvoie
                    ligneProformas {
                        _id
                        designation
                        quantite
                        dureeLivraison
                        prixSupplementaire
                        montant
                        remise
                        unit
                        service {
                            _id
                            libelle
                            type
                            etat
                            prix
                            nature
                            description
                            country {
                        _id
                        name
                        code
                      }
                            fullCount
                            tarif {
                                minQuantity
                                maxQuantity
                                prix
                            }
                        }
                        fraisDivers {
                            libelle
                            montant
                            tva
                        }
                    }
                    client {
                        _id
                        email
                        telephone
                        adresse
                        pays {
                     _id
          name
          code
          tauxTVA
          phoneNumber
                  }
                        ... on ClientMoral {
                            _id
                            raisonSociale
                            logo
                            email
                            telephone
                            adresse
                           pays {
                     _id
          name
          code
          tauxTVA
          phoneNumber
                  }
                        }
                        ... on ClientPhysique {
                            _id
                            nom
                            prenom
                            sexe
                            email
                            telephone
                            adresse
                            pays {
                     _id
          name
          code
          tauxTVA
          phoneNumber
                  }
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
    try {
      List<ProformaModel> proformas = [];
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['proformas'];
        if (data != null) {
          for (var proforma in data) {
            proformas.add(ProformaModel.fromJson(proforma));
          }
        } else {
          throw RequestMessage.failgettingDataMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
      return proformas;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<ProformaModel>> getArchivedProformas() async {
    var body = '''
                query ArchivedProformas {
                  archivedProformas {
                    _id
                    reference
                    reduction{
                      valeur
                      unite
                    }
                    tva
                    tauxTVA
                    dateEnregistrement
                    status
                    montant
                    dateEtablissementProforma
                    garantyTime
                    dateEnvoie
                    ligneProformas {
                        _id
                        designation
                        quantite
                        dureeLivraison
                        prixSupplementaire
                        montant
                        remise
                        unit
                        service {
                            _id
                            libelle
                            type
                            etat
                            prix
                            nature
                            description
                            country {
                        _id
                        name
                        code
                      }
                            fullCount
                            tarif {
                                minQuantity
                                maxQuantity
                                prix
                            }
                        }
                        fraisDivers {
                            libelle
                            montant
                            tva
                        }
                    }
                    client {
                        _id
                        email
                        telephone
                        adresse
                       pays {
                     _id
          name
          code
          tauxTVA
          phoneNumber
                  }
                        ... on ClientMoral {
                            _id
                            raisonSociale
                            logo
                            email
                            telephone
                            adresse
                           pays {
                     _id
          name
          code
          tauxTVA
          phoneNumber
                  }
                        }
                        ... on ClientPhysique {
                            _id
                            nom
                            prenom
                            sexe
                            email
                            telephone
                            adresse
                            pays {
                     _id
          name
          code
          tauxTVA
          phoneNumber
                  }
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
    List<ProformaModel> proformas = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['archivedProformas'];
      if (data != null) {
        for (var proforma in data) {
          proformas.add(ProformaModel.fromJson(proforma));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return proformas;
  }

  static Future<List<ProformaModel>> getProformasAttente() async {
    var body = '''
                query Proformas {
                  proformas {
                    _id
                    reference
                    status
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
        throw RequestMessage.failgettingDataMessage;
      },
    );
    List<ProformaModel> proformas = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['proformas'];

      if (data != null) {
        for (var proforma in data) {
          proformas.add(ProformaModel.fromJson(proforma));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return proformas
        .where((proforma) => proforma.status! == StatusProforma.wait)
        .toList();
  }

  static Future<RequestResponse> validerProforma({
    required String proformaId,
    DateTime? dateEtablissementFacture,
    required List<FactureAcompteModel> facturesAcompte,
    required List<BanqueModel> banques,
  }) async {
    // Initialisation de la requête
    String body = '''
    mutation ValiderProforma {
    validerProforma(key: "$proformaId",''';

    if (dateEtablissementFacture != null) {
      body +=
          'dateEtablissementFacture: ${dateEtablissementFacture.millisecondsSinceEpoch},';
    }
    body += 'banquesIds: [';
    for (var banque in banques) {
      body += '"${banque.id}"';
    }
    body += '],';

    body += 'facturesAcompte: [';
    for (var factureAcompte in facturesAcompte) {
      body +=
          '{rang: ${factureAcompte.rang}, pourcentage: ${factureAcompte.pourcentage}, isPaid: ${factureAcompte.isPaid}, canPenalty: ${factureAcompte.canPenalty}, dateEnvoieFacture: ${factureAcompte.dateEnvoieFacture.millisecondsSinceEpoch}}';
    }
    body += '],';
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
        var data = jsonData['data']['validerProforma'];
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
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<RequestResponse> createProformat({
    required String clientId,
    DateTime? dateEtablissementProforma,
    required int garantie,
    required DateTime dateEnvoie,
    bool? tva,
    required List<LigneDto> lignes,
  }) async {
    // Initialisation de la requête
    String body = '''
    mutation CreateProforma {
      createProforma(
        clientId: "$clientId",
        tva: $tva,
        ligneProformas: [
  ''';
    lignes.map((ligne) {
      body += '${ligne.toJson()}';
    }).toList();
    body += '],';

    // Ajout de la garantie si elle existe
    body += 'garantyTime: $garantie,';

    body += 'dateEnvoie: ${dateEnvoie.millisecondsSinceEpoch},';

    // Ajout de la date d'établissement si elle existe
    if (dateEtablissementProforma != null) {
      body +=
          'dateEtablissementProforma: ${dateEtablissementProforma.millisecondsSinceEpoch},';
    }

    body += '''
      )
    }
  ''';
    try {
      // Envoi de la requête HTTP
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

      // Vérification de la réponse
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createProforma'];
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

  static Future<RequestResponse> updateProformat({
    required String id,
    DateTime? dateEtablissementProforma,
    String? clientId,
    int? garantie,
    DateTime? dateEnvoie,
    ReductionModel? reduction,
    StatusProforma? statut,
    bool? tva,
  }) async {
    var body = '''
    mutation UpdateProforma {
     updateProforma(
     key:"$id",
  ''';
    if (garantie != null) {
      body += 'garantyTime: $garantie,';
    }
    if (clientId != null) {
      body += 'clientId: "$clientId",';
    }
    if (tva != null) {
      body += 'tva: $tva,';
    }

    if (dateEnvoie != null) {
      body += 'dateEnvoie: ${dateEnvoie.millisecondsSinceEpoch},';
    }
    if (reduction != null && reduction.valeur != 0) {
      body +=
          'reduction: {unite: ${reduction.unite != null ? '"${reduction.unite}"' : null}, valeur: ${reduction.valeur}}';
    }

    if (dateEtablissementProforma != null) {
      body +=
          'dateEtablissementProforma: ${dateEtablissementProforma.millisecondsSinceEpoch},';
    }
    if (statut != null) {
      body += 'status: ${statusProformaToString(statut)},';
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
        var data = jsonData['data']['updateProforma'];
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
        message: RequestMessage.serverErrorMessage,
        status: PopupStatus.serverError,
      );
    }
  }
}
