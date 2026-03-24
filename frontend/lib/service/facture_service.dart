import 'dart:convert';
import '../dto/facturation/ligne_dto.dart';
import '../model/entreprise/banque.dart';
import '../model/commentaire_model.dart';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/facturation/enum_facture.dart';

import '../model/facturation/facture_acompte.dart';
import '../model/facturation/reduction_model.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import '../model/facturation/facture_model.dart';
import 'request_header.dart';

class FactureService {
  static Future<List<FactureModel>> getUnPaidFactures() async {
    var body = '''
    query UnpaidFacture {
    unpaidFacture {
        _key
        reference
        reduction{
        unite
        valeur
        }
        tva
        tauxTVA
        dateEnregistrement
        status
        montant
        dateEtablissementFacture
        regenerate
        blocked
        secreteKey
        delaisPayment
        generatePeriod
        dateDebutFacturation
        isConvertFromProforma
        type
        client {
            _key
            email
            telephone
            adresse
            nature
            etat
            dateEnregistrement
            fullCount
            pays {
                     _key
          name
          code
          tauxTVA
          phoneNumber
                  }
            ... on ClientMoral {
                _key
                raisonSociale
                logo
                email
                nature
                telephone
                adresse
                etat
                dateEnregistrement
                fullCount
                pays {
                     _key
          name
          code
          tauxTVA
          phoneNumber
                  }
            }
            ... on ClientPhysique {
                _key
                nom
                prenom
                sexe
                nature
                email
                telephone
                adresse
                etat
                dateEnregistrement
                fullCount
                pays {
                     _key
          name
          code
          tauxTVA
          phoneNumber
                  }
            }
        }
        ligneFactures {
            _key
            designation
            unit
            quantite
            dureeLivraison
            montant
            prixSupplementaire
            remise
            service {
                _key
                libelle
                type
                etat
                prix
                nature
                description
                country {
                        _key
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
        banques {
            _key
            name
            codeGuichet
            codeBanque
            cleRIB
            codeBIC
            numCompte
            type
            logo
            soldeReel
            soldeTheorique
            country {
                        _key
                        name
                        code
                      }
        }
      facturesAcompte {
            rang
            pourcentage
            datePayementEcheante
            isPaid
            isSent
            canPenalty
            penalty {
            montant
            isPaid
            nombreRetard
            }
            dateEnvoieFacture
            oldPenalties {
              libelle
              montant
              nbreRetard
            }
        }
        payements {
          _key
          libelle
          type
          reference
          referenceTransaction
          status
          montant
          moyenPayement{
            _key
            libelle
          }
          validate {
              validateStatus
              date
              validater {
                  _key
                  personnel {
                      _key
                      nom
                      prenom
                  }
              }
              commentaire
          }
          pieceJustificative
          user {
              _key
              personnel {
                  _key
                  nom
                  prenom
                  email
                  telephone
              }
          }
          dateOperation
          bank {
              _key
              name
              codeGuichet
              codeBanque
              codeBIC
              numCompte
              cleRIB
              type
              logo
              soldeReel
              soldeTheorique
          }
          dateEnregistrement
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
    List<FactureModel> factures = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['unpaidFacture'];
      if (data != null) {
        for (var facture in data) {
          factures.add(FactureModel.fromJson(facture));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return factures;
  }

  static Future<List<FactureModel>> getNewReccurenteFactures() async {
    var body = '''
    query NewRecurrentFacture {
    newRecurrentFacture {
        _key
        reference
        reduction{
        unite
        valeur
        }
        tva
        tauxTVA
        dateEnregistrement
        status
        montant
        blocked
        delaisPayment
        dateEtablissementFacture
        regenerate
        isDeletable
        secreteKey
        generatePeriod
        dateDebutFacturation
        isConvertFromProforma
        type
        client {
            _key
            email
            telephone
            adresse
            nature
            etat
            dateEnregistrement
            fullCount
            pays {
                     _key
          name
          code
          tauxTVA
          phoneNumber
                  }
            ... on ClientMoral {
                _key
                raisonSociale
                logo
                email
                nature
                telephone
                adresse
                etat
                dateEnregistrement
                fullCount
                pays {
                     _key
          name
          code
          tauxTVA
          phoneNumber
                  }
            }
            ... on ClientPhysique {
                _key
                nom
                prenom
                sexe
                nature
                email
                telephone
                adresse
                etat
                dateEnregistrement
                fullCount
                pays {
                     _key
          name
          code
          tauxTVA
          phoneNumber
                  }
            }
        }
        ligneFactures {
            _key
            designation
            unit
            quantite
            dureeLivraison
            montant
            prixSupplementaire
            remise
            service {
                _key
                libelle
                type
                etat
                nature
                prix
                description
                country {
                        _key
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
        banques {
            _key
            name
            codeGuichet
            codeBanque
            cleRIB
            codeBIC
            numCompte
            type
            logo
            soldeReel
            soldeTheorique
            country {
              _key
              name
              code
            }
        }
      facturesAcompte {
            rang
            pourcentage
            datePayementEcheante
            isPaid
            canPenalty
            dateEnvoieFacture
            penalty {
            montant
            isPaid
            nombreRetard
            }
            oldPenalties {
              libelle
              montant
              nbreRetard
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
        throw RequestMessage.failgettingDataMessage;
      },
    );
    List<FactureModel> factures = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['newRecurrentFacture'];
      if (data != null) {
        for (var facture in data) {
          factures.add(FactureModel.fromJson(facture));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return factures;
  }

  static Future<List<FactureModel>> getPaidFacture() async {
    try {
      var body = '''
    query PaidFactures {
    paidFactures {
        _key
        reference
                reduction{
        unite
        valeur
        }
        tva
        tauxTVA
        dateEnregistrement
        status
        montant
        dateEtablissementFacture
        regenerate
        generatePeriod
        secreteKey
        dateDebutFacturation
        isConvertFromProforma
        type
        client {
            _key
            email
            telephone
            adresse
            nature
            etat
            dateEnregistrement
            fullCount
            pays {
                     _key
          name
          code
          tauxTVA
          phoneNumber
                  }
            ... on ClientMoral {
                _key
                raisonSociale
                logo
                email
                nature
                telephone
                adresse
                etat
                dateEnregistrement
                fullCount
                pays {
                     _key
          name
          code
          tauxTVA
          phoneNumber
                  }
            }
            ... on ClientPhysique {
                _key
                nom
                prenom
                sexe
                nature
                email
                telephone
                adresse
                etat
                dateEnregistrement
                fullCount
               pays {
                     _key
          name
          code
          tauxTVA
          phoneNumber
                  }
            }
        }
        ligneFactures {
            _key
            designation
            unit
            quantite
            dureeLivraison
            montant
            prixSupplementaire
            remise
            service {
              _key
              libelle
              type                                      
              etat
              nature
              prix
              description
              country {
                        _key
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
        payements {
            _key
            libelle
            type
            montant
            reference
            referenceTransaction
status
            user {
              _key
              personnel {
                  _key
                  nom
                  prenom
                  email
                  telephone
              }
            }
            validate {
            validateStatus
            date
            validater {
                _key
                personnel {
                    _key
                    nom
                    prenom
                }
            }
            commentaire
        }
            pieceJustificative
            moyenPayement{
                      _key
                      libelle
                      }
            dateOperation
            dateEnregistrement
            bank {
                _key
                name
                codeGuichet
                            codeBIC
            numCompte
                codeBanque
                cleRIB
                logo
                soldeReel
                soldeTheorique
            }
        }
        banques {
            _key
            name
            codeGuichet
            codeBanque
            type
            cleRIB
            logo
            soldeReel
            soldeTheorique
        }
        
      facturesAcompte {
            rang
            pourcentage
            datePayementEcheante
            isPaid
            canPenalty
            dateEnvoieFacture
            penalty {
            montant
            isPaid
            nombreRetard
            }
            oldPenalties {
                libelle
                montant
                nbreRetard
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
        throw onError.toString();
      }).timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          throw RequestMessage.failgettingDataMessage;
        },
      );
      List<FactureModel> factures = [];
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['paidFactures'];
        if (data != null) {
          for (var facture in data) {
            factures.add(FactureModel.fromJson(facture));
          }
        } else {
          throw RequestMessage.failgettingDataMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
      return factures;
    } catch (err) {
       

      throw err.toString();
    }
  }

  static Future<dynamic> getPayementFactures() async {
    var body = '''
              query PayementFacture {
                payementFacture {
                    _key
                    reference
                            reduction{
        unite
        valeur
        }
                    tva
                    tauxTVA
                    status
                    montant
                    dateEtablissementFacture
                    type
                    facturesAcompte {
                        rang
                        canPenalty
                        dateEnvoieFacture
                        isSent
                        pourcentage
                        datePayementEcheante
                        isPaid
                    }
                    client {
                        _key
                        ... on ClientMoral {
                            _key
                            raisonSociale
                        }
                        ... on ClientPhysique {
                            _key
                            nom
                            prenom
                        }
                    }
                    payements {
                      _key
                      libelle
                      type
                      reference
                      referenceTransaction
status
                      montant
                      moyenPayement{
                      _key
                      libelle
                      type
                      }
                      validate {
                          validateStatus
                          date
                          validater {
                              _key
                              personnel {
                                  _key
                                  nom
                                  prenom
                              }
                          }
                          commentaire
                      }
                      pieceJustificative
                      user {
                          _key
                          personnel {
                              _key
                              nom
                              prenom
                              email
                              telephone
                          }
                      }
                      dateOperation
                      bank {
                          _key
                          type
                          name
                          codeGuichet
                          codeBanque
                          codeBIC
                          numCompte
                          cleRIB
                          logo
                          soldeReel
                          soldeTheorique
                      }
                      dateEnregistrement
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
      FactureModel.factureErr = RequestMessage.failgettingDataMessage;
      return FactureModel.factureErr;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        FactureModel.factureErr = RequestMessage.failgettingDataMessage;
        return FactureModel.factureErr;
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['payementFacture'];
      List<FactureModel> factures = [];
      if (data != null) {
        for (var facture in data) {
          factures.add(FactureModel.fromJson(facture));
        }
        return factures;
        // .where((facture) {
        //   return facture.facturesAcompte.any((acompte) {
        //     return acompte.datePayementEcheante != null && !acompte.isPaid!;
        //   });
        // }).toList();
      } else {
        FactureModel.factureErr = RequestMessage.failgettingDataMessage;
      }
    } else {
      FactureModel.factureErr =
          jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<List<FactureModel>> getUnPaidFacturesForDashboard() async {
    var body = '''
              query UnpaidFacture {
                unpaidFacture {
                    _key
                    reference
                    facturesAcompte {
                      rang
                      pourcentage
                      canPenalty
                      datePayementEcheante
                      isPaid
                      dateEnvoieFacture
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
      FactureModel.factureErr = RequestMessage.failgettingDataMessage;
      return FactureModel.factureErr;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        FactureModel.factureErr = RequestMessage.failgettingDataMessage;
        return FactureModel.factureErr;
      },
    );
    List<FactureModel> factures = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['unpaidFacture'];

      if (data != null) {
        for (var facture in data) {
          factures.add(FactureModel.fromJson(facture));
        }
      } else {
        FactureModel.factureErr = RequestMessage.failgettingDataMessage;
      }
    } else {
      FactureModel.factureErr =
          jsonDecode(response.body)['errors'][0]['message'];
    }
    return factures;
  }

  static Future<RequestResponse> createFacture({
    required String clientKey,
    DateTime? dateEtablissementFacture,
    DateTime? dateDebutFacturation,
    required bool tva,
    required TypeFacture type,
    required List<BanqueModel> banques,
    int? delaisPayment,
    int? generatePeriod,
    required List<FactureAcompteModel>? facturesAcompte,
    required List<LigneDto> lignes,
  }) async {
    String body = '''
    mutation CreateFacture {
      createFacture(
        clientKey: "$clientKey",
        tva: $tva,
        type: ${type.name},
        ligneFactures: [
            ''';
    lignes.map((ligne) {
      body += '${ligne.toJson()}';
    }).toList();
    body += '],';

    body += 'banquesKeys: [';
    for (var banque in banques) {
      body += '"${banque.key}"';
    }
    body += '],';
    if (dateEtablissementFacture != null) {
      body +=
          'dateEtablissementFacture: ${dateEtablissementFacture.millisecondsSinceEpoch},';
    }

    if (facturesAcompte != null) {
      body += 'facturesAcompte: [';
      for (var factureAcompte in facturesAcompte) {
        body +=
            '{rang: ${factureAcompte.rang}, canPenalty: ${factureAcompte.canPenalty}, pourcentage: ${factureAcompte.pourcentage}, isPaid: ${factureAcompte.isPaid},  dateEnvoieFacture: ${factureAcompte.dateEnvoieFacture.millisecondsSinceEpoch}}';
      }
      body += '],';
    }
    if (dateDebutFacturation != null) {
      body +=
          'dateDebutFacturation: ${dateDebutFacturation.millisecondsSinceEpoch},';
    }
    if (delaisPayment != null) {
      body += 'delaisPayment: $delaisPayment,';
    }
    if (generatePeriod != null) {
      body += 'generatePeriod: $generatePeriod,';
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
        var data = jsonData['data']['createFacture'];
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

  static Future<dynamic> getRecurrentFactureByClient(
      {required String clientKey}) async {
    var body = '''
               query RecurrentFactureByClient {
                  recurrentFactureByClient(clientKey: "$clientKey") {
                      _key
                      reference
                      secreteKey
                      ligneFactures {
                          _key
                          designation
                          montant
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
      FactureModel.factureErr = RequestMessage.failgettingDataMessage;
      return FactureModel.factureErr;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        FactureModel.factureErr = RequestMessage.failgettingDataMessage;
        return FactureModel.factureErr;
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['recurrentFactureByClient'];
      List<FactureModel> factures = [];
      if (data != null) {
        for (var facture in data) {
          factures.add(FactureModel.fromJson(facture));
        }
        return factures;
      } else {
        FactureModel.factureErr = RequestMessage.failgettingDataMessage;
      }
    } else {
      FactureModel.factureErr =
          jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<RequestResponse> updateFacture({
    required String factureKey,
    String? clientKey,
    DateTime? dateEtablissement,
    ReductionModel? reduction,
    int? generatePeriod,
    int? delaisPayment,
    DateTime? dateDebutFacturation,
    bool? tva,
    List<FactureAcompteModel>? facturesAcompte,
    List<BanqueModel>? banques,
    CommentModel? comment,
  }) async {
    var body = '''
    mutation UpdateFacture {
      updateFacture(
        key: "$factureKey",
  ''';

    if (clientKey != null) {
      body += 'clientKey: "$clientKey", ';
    }
    if (dateEtablissement != null) {
      body +=
          'dateEtablissementFacture: ${dateEtablissement.millisecondsSinceEpoch}, ';
    }
    if (dateDebutFacturation != null) {
      body +=
          'dateDebutFacturation: ${dateDebutFacturation.millisecondsSinceEpoch}, ';
    }
    if (generatePeriod != null) {
      body += 'generatePeriod: $generatePeriod, ';
    }
    if (delaisPayment != null) {
      body += 'delaisPayment: $delaisPayment, ';
    }

    if (reduction != null) {
      body +=
          'reduction: {unite: ${reduction.unite != null ? '"${reduction.unite}"' : null}, valeur: ${reduction.valeur}}';
    }
    if (banques != null) {
      body += 'banquesKeys: [';
      for (var banque in banques) {
        body += '"${banque.key}"';
      }
      body += '],';
    }
    if (comment != null) {
      body +=
          'commentaire: {message: "${comment.message}",editer: "${comment.editer!.key!}", date: ${comment.date.millisecondsSinceEpoch}}, ';
    }
    if (facturesAcompte != null) {
      body += 'facturesAcompte: [';
      for (var factureAcompte in facturesAcompte) {
        body +=
            '{rang: ${factureAcompte.rang}, canPenalty: ${factureAcompte.canPenalty}, pourcentage: ${factureAcompte.pourcentage}, dateEnvoieFacture: ${factureAcompte.dateEnvoieFacture.millisecondsSinceEpoch}, isPaid: ${factureAcompte.isPaid},';
        if (factureAcompte.datePayementEcheante != null) {
          body +=
              'datePayementEcheante: ${factureAcompte.datePayementEcheante!.millisecondsSinceEpoch},';
        }
        body += '}';
      }
      body += '], ';
    }
    if (tva != null) {
      body += 'tva: $tva, ';
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
        var data = jsonData['data']['updateFacture'];
        if (data != null) {
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

  static Future<RequestResponse> deleteFacture({
    required String factureKey,
  }) async {
    var body = '''
    mutation DeleteFacture {
      deleteFacture(
        key: "$factureKey",
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
        var data = jsonData['data']['deleteFacture'];
        if (data != null) {
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

  static Future<RequestResponse> updateFactureAccompte({
    required String factureKey,
    bool? canPenalty,
    DateTime? datePayementEcheante,
    DateTime? dateEnvoieFacture,
    bool? isSent,
    CommentModel? comment,
    required int rang,
  }) async {
    var body = '''
   mutation UpdateFactureAccompte {
    updateFactureAccompte(key: "$factureKey", rang: $rang,
    ''';
    if (datePayementEcheante != null) {
      body +=
          'datePayementEcheante: ${datePayementEcheante.millisecondsSinceEpoch},';
    }
    if (dateEnvoieFacture != null) {
      body += 'dateEnvoieFacture: ${dateEnvoieFacture.millisecondsSinceEpoch},';
    }

    if (comment != null) {
      body +=
          'commentaire: {message: "${comment.message}", editer: "${comment.editer}", date: ${comment.date.millisecondsSinceEpoch}}, ';
    }
    if (isSent != null) {
      body += 'isSent: $isSent,';
    }
    if (canPenalty != null) {
      body += 'canPenalty: $canPenalty,';
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
        var data = jsonData['data']['updateFactureAccompte'];
        if (data != null) {
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

  static Future<RequestResponse> stoppregeneration({
    required String secreteKey,
  }) async {
    var body = '''
    mutation StopperService {
        stopperService(
            secretekey: "$secreteKey"
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
        var data = jsonData['data']['stopperService'];
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

  static Future<RequestResponse> startregeneration({
    required FactureModel facture,
  }) async {
    var body = '''
  mutation RestartService {
    restartService(factureKey: "${facture.key}", secretekey: "${facture.secreteKey}")
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
        var data = jsonData['data']['restartService'];
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
