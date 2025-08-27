import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/model/commentaire_model.dart';
import 'package:frontend/model/flux_financier/tranche_payement_credit.dart';
import 'package:frontend/model/flux_financier/validate_flux_model.dart';
import '../global/constant/request_management_value.dart';
import '../model/client/client_model.dart';
import '../model/entreprise/banque.dart';
import '../model/flux_financier/bilan.dart';
import '../model/flux_financier/flux_financier_model.dart';
import '../model/flux_financier/type_flux_financier.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../model/moyen_paiement_model.dart';
import '../model/request_response.dart';
import 'request_header.dart';

class FluxFinancierService {
  static Future<RequestResponse> createFluxFinancier({
    required String libelle,
    required FluxFinancierType type,
    required ClientModel client,
    required double montant,
    DateTime? dateOperation,
    BuyingManner? modePayement,
    double? montantPaye,
    List<TranchePayementModel?>? tranchePayement,
    required BanqueModel banque,
    required MoyenPaiementModel moyenPayement,
    required referenceTransaction,
    required String userId,
    PlatformFile? file,
  }) async {
    try {
      String body = '''
        mutation CreateFluxFinancier(\$pieceJustificative: Upload) {
            createFluxFinancier(
                libelle: "$libelle",
                referenceTransaction: "$referenceTransaction",
                type: ${fluxFinancierTypeToString(type)},
                montant: $montant,
                moyenPayement: ${moyenPayement.toJson()},
                userId: "$userId",        
                clientId: "${client.id}",        
        ''';
      body += 'bankId: "${banque.id}",';

      if (dateOperation != null) {
        body += 'dateOperation: ${dateOperation.millisecondsSinceEpoch},';
      }
      if (modePayement == null) {
        body += 'modePayement: ${buyingMannerToString(modePayement!)}';
        if (modePayement != BuyingManner.total && tranchePayement != null) {
          body += 'tranchePayement: [';
          for (var tranche in tranchePayement) {
            body += '${tranche?.toJson()}';
          }
          body += '],';
        }
      }
      if (montantPaye == null) {
        body += 'montantPaye: $montantPaye';
      }

      body += 'pieceJustificative: \$pieceJustificative';
      body += '''
            )
        }
        ''';

      // Création de la requête multipart
      var multipartRequest = http.MultipartRequest('POST', Uri.parse(serverUrl))
        ..fields['operations'] = jsonEncode({
          "query": body,
          "variables": {
            "pieceJustificative": null,
          }
        });

      multipartRequest.fields['map'] = jsonEncode({
        "pieceJustificative": ["variables.pieceJustificative"]
      });

      if (file != null) {
        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            'pieceJustificative',
            file.bytes!,
            filename: file.name,
            contentType: MediaType("application", "octet-stream"),
          ),
        );
      }

      multipartRequest.headers.addAll({...getHeaders()});

      var streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          return RequestResponse.response(
            status: PopupStatus.customError,
            message: RequestMessage.timeoutMessage,
          );
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createFluxFinancier'];
        if (data != null) {
          return RequestResponse(
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
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
        status: PopupStatus.serverError,
        message: "Une erreur s'est produite : $error",
      );
    }
  }

  static Future<RequestResponse> updateFluxFinancier({
    required String key,
    String? libelle,
    required double? montant,
    required DateTime? dateOperation,
    required MoyenPaiementModel? moyenPayement,
    required String? referenceTransaction,
    required BanqueModel? banque,
    required ClientModel? client,
    required PlatformFile? file,
  }) async {
    try {
      String body = '''
       mutation UpdateFluxFinancier (\$pieceJustificative: Upload){
        updateFluxFinancier(
            key: "$key",
        ''';
      if (dateOperation != null) {
        body += 'dateOperation: ${dateOperation.millisecondsSinceEpoch},';
      }
      if (libelle != null) {
        body += 'libelle: "$libelle",';
      }
      if (referenceTransaction != null) {
        body += 'referenceTransaction: "$referenceTransaction",';
      }
      if (montant != null) {
        body += 'montant: $montant,';
      }
      if (moyenPayement != null) {
        body += 'moyenPayement: ${moyenPayement.toJson()},';
      }
      if (banque != null) {
        body += 'bankId: "${banque.id}"';
      }
      if (client != null) {
        body += 'clientId: "${client.id}"';
      }
      body += 'pieceJustificative: \$pieceJustificative';

      body += '''
            )
        }
        ''';
      bool isFileModified = file != null && file.bytes != null;
      bool isFileUnchanged = file != null && file.bytes == null;

      final variables = {
        "pieceJustificative": isFileUnchanged ? "__unchanged__" : null
      };
      // Création de la requête multipart
      http.MultipartRequest multipartRequest = http.MultipartRequest(
          'POST', Uri.parse(serverUrl))
        ..fields['operations'] =
            jsonEncode(<String, Object>{"query": body, "variables": variables});

      multipartRequest.fields['map'] = jsonEncode(<String, List<String>>{
        "pieceJustificative": ["variables.pieceJustificative"]
      });

      if (isFileModified) {
        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            'pieceJustificative',
            file.bytes!,
            filename: file.name,
            contentType: MediaType("application", "octet-stream"),
          ),
        );
      } else {
        multipartRequest.fields['map'] = json.encode({});
      }

      multipartRequest.headers.addAll({...getHeaders()});

      var streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          return RequestResponse.response(
            status: PopupStatus.customError,
            message: RequestMessage.timeoutMessage,
          );
        },
      );

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateFluxFinancier'];
        if (data != null) {
          return RequestResponse(
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
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
        status: PopupStatus.serverError,
        message: "Une erreur s'est produite : $error",
      );
    }
  }

  static Future<RequestResponse> validateFluxFinancier({
    required String key,
    required ValidateFluxModel validateFlux,
    CommentModel? comment,
  }) async {
    try {
      String body = '''
       mutation ValidateFluxFinancier {
        validateFluxFinancier(
        key: "$key"
        validate: { validateStatus: ${fluxFinancierStatusToString(validateFlux.validateStatus)}, validater: "${validateFlux.validater.id!}", date: ${DateTime.now().millisecondsSinceEpoch}, commentaire:"${validateFlux.commentaire}"}
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
            message: RequestMessage.timeoutMessage,
            status: PopupStatus.customError,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var validateFluxFinancier = jsonData['data']['validateFluxFinancier'];
        if (validateFluxFinancier == RequestMessage.success) {
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
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<RequestResponse> deleteFluxFinancier({
    required String key,
  }) async {
    try {
      String body = '''
       mutation DeleteFluxFinancier {
          deleteFluxFinancier(key: "$key")
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
            message: RequestMessage.timeoutMessage,
            status: PopupStatus.customError,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var deleteFluxFinancier = jsonData['data']['deleteFluxFinancier'];
        if ((deleteFluxFinancier == RequestMessage.success)) {
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
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<List<FluxFinancierModel>> getInputs() async {
    var body = '''
               query FluxFinanciers {
                  fluxFinanciers(type: input) {
                      _id
                      libelle
                      type
                      montant
                      reference
                      referenceTransaction
                      status
                      factureId
                      moyenPayement{
                      _id
                      libelle
                      type
                      }
                      pieceJustificative
                      isFromSystem
                      client {
                        _id
                        ... on ClientMoral {
                            _id
                            raisonSociale
                        }
                        ... on ClientPhysique {
                            _id
                            nom
                            prenom
                        }
                    }
                      validate {
                          validateStatus
                          date
                          validater {
                              _id
                              personnel {
                                  _id
                                  nom
                                  prenom
                              }
                          }
                          commentaire
                      }
                      
                      user {
                          _id
                          personnel {
                              _id
                              nom
                              prenom
                              email
                              telephone
                          }
                      }
                      dateOperation
                      bank {
            _id
            name
            type
            codeGuichet
                        codeBIC
            numCompte
            codeBanque
            cleRIB
            soldeReel
            soldeTheorique
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
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );
    List<FluxFinancierModel> fluxFinanciers = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['fluxFinanciers'];
      if (data != null) {
        for (var fluxFinancier in data) {
          fluxFinanciers.add(FluxFinancierModel.fromJson(fluxFinancier));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return fluxFinanciers;
  }
  static Future<List<FluxFinancierModel>> getDebt() async {
    var body = '''
               query DebtFluxFinanciers {
                  debtFluxFinanciers() {
                      _id
                      libelle
                      type
                      montant
                      reference
                      referenceTransaction
                      status
                      factureId
                      moyenPayement{
                      _id
                      libelle
                      type
                      }
                      pieceJustificative
                      isFromSystem
                      client {
                        _id
                        ... on ClientMoral {
                            _id
                            raisonSociale
                        }
                        ... on ClientPhysique {
                            _id
                            nom
                            prenom
                        }
                    }
                      validate {
                          validateStatus
                          date
                          validater {
                              _id
                              personnel {
                                  _id
                                  nom
                                  prenom
                              }
                          }
                          commentaire
                      }
                      
                      user {
                          _id
                          personnel {
                              _id
                              nom
                              prenom
                              email
                              telephone
                          }
                      }
                      dateOperation
                      bank {
            _id
            name
            type
            codeGuichet
                        codeBIC
            numCompte
            codeBanque
            cleRIB
            soldeReel
            soldeTheorique
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
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );
    List<FluxFinancierModel> fluxFinanciers = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['debtFluxFinanciers'];
      if (data != null) {
        for (var fluxFinancier in data) {
          fluxFinanciers.add(FluxFinancierModel.fromJson(fluxFinancier));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return fluxFinanciers;
  }

  static Future<List<FluxFinancierModel>> getUnValidatedFlux() async {
    var body = '''
               query UnValidatedFluxFinanciers {
                  unValidatedFluxFinanciers {
                      _id
                      libelle
                      reference
                      referenceTransaction
                      status
                      type
                      montant
                      moyenPayement{
                      _id
                      libelle
                      type
                      }
                      dateOperation
                      dateEnregistrement
                      pieceJustificative
                      client {
                        _id
                        ... on ClientMoral {
                            _id
                            raisonSociale
                        }
                        ... on ClientPhysique {
                            _id
                            nom
                            prenom
                        }
                    }
                      validate {
                            validateStatus
                            date
                            validater {
                                _id
                                personnel {
                                    _id
                                    nom
                                    prenom
                                }
                            }
                            commentaire
                        }                
                      bank {
            _id
            name
            type
            codeGuichet
            codeBanque
                        codeBIC
            numCompte
            cleRIB
            soldeReel
            soldeTheorique
        }
                      user {
                          _id
                          personnel {
                              _id
                              nom
                              prenom
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
    List<FluxFinancierModel> fluxFinanciers = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['unValidatedFluxFinanciers'];
      // print(data);
      if (data != null) {
        for (var fluxFinancier in data) {
          fluxFinanciers.add(FluxFinancierModel.fromJson(fluxFinancier));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return fluxFinanciers;
  }

  static Future<List<FluxFinancierModel>> getArchiveFlux() async {
    var body = '''
               query ArchiveFluxFinanciers {
                  archiveFluxFinanciers {
                      _id
                      libelle
                      reference
                      referenceTransaction
                      status
                      type
                      montant
                      factureId
                      moyenPayement{
                      _id
                      libelle
                      type
                      }
                      dateOperation
                      dateEnregistrement
                      pieceJustificative
                      client {
                        _id
                        ... on ClientMoral {
                            _id
                            raisonSociale
                        }
                        ... on ClientPhysique {
                            _id
                            nom
                            prenom
                        }
                    }
                      validate {
                            validateStatus
                            date
                            validater {
                                _id
                                personnel {
                                    _id
                                    nom
                                    prenom
                                }
                            }
                            commentaire
                        }                
                      bank {
            _id
            name
            codeGuichet
            type
            codeBanque
                        codeBIC
            numCompte
            cleRIB
            soldeReel
            soldeTheorique
        }
                      user {
                          _id
                          personnel {
                              _id
                              nom
                              prenom
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
    List<FluxFinancierModel> fluxFinanciers = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['archiveFluxFinanciers'];
      if (data != null) {
        for (var fluxFinancier in data) {
          fluxFinanciers.add(FluxFinancierModel.fromJson(fluxFinancier));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return fluxFinanciers;
  }

  static Future<List<FluxFinancierModel>> getBanqueTransaction({
    required String banqueId,
    required DateTime debut,
    required DateTime fin,
    required FluxFinancierStatus? status,
  }) async {
    var body = '''
               query FluxFinanciersByBank {
                  fluxFinanciersByBank(banque: "$banqueId", debut: ${debut.millisecondsSinceEpoch}, fin: ${fin.millisecondsSinceEpoch},
                  ''';
    if (status != null) {
      body += 'status: ${fluxFinancierStatusToString(status)}';
    }
    body += '''
                  
                  ) {
                      _id
                      libelle
                      type
                      montant
                      reference
                      referenceTransaction
                      status
                      moyenPayement{
                      _id
                      libelle
                      type
                      }
                      client {
                        _id
                        ... on ClientMoral {
                            _id
                            raisonSociale
                        }
                        ... on ClientPhysique {
                            _id
                            nom
                            prenom
                        }
                    }
                      pieceJustificative
                      user {
                          _id
                          personnel {
                              _id
                              nom
                              prenom
                              email
                              telephone
                          }
                      }
                      dateOperation
                      bank {
            _id
            name
            type
            codeGuichet
            codeBanque
                        codeBIC
            numCompte
            cleRIB
            soldeReel
            soldeTheorique
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
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );
    List<FluxFinancierModel> fluxFinanciers = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['fluxFinanciersByBank'];
      if (data != null) {
        for (var fluxFinancier in data) {
          fluxFinanciers.add(FluxFinancierModel.fromJson(fluxFinancier));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return fluxFinanciers;
  }

  static Future<Bilan> getAllBilanData(
      {DateTime? debut,
      DateTime? fin,
      required FluxFinancierType? type}) async {
    var body = '''
               query Bilan {
                  bilan(begin:${debut?.millisecondsSinceEpoch},
                  end: ${fin?.millisecondsSinceEpoch},
                  ''';
    if (type != null) {
      body += 'type:${fluxFinancierTypeToString(type)}';
    }
    body += '''
                ) {
                      total
                      input
                      output
                      fluxFinanciers {
                      _id
                      libelle
                      type
                      montant
                      reference
                      referenceTransaction
                      status
                      client {
                        _id
                        ... on ClientMoral {
                            _id
                            raisonSociale
                        }
                        ... on ClientPhysique {
                            _id
                            nom
                            prenom
                        }
                    }
                      moyenPayement{
                      _id
                      libelle
                      type
                      }
                      pieceJustificative
                      user {
                          _id
                          personnel {
                              _id
                              nom
                              prenom
                              email
                              telephone
                          }
                      }
                      
                      dateOperation
                      bank {
                        _id
                        name
                        type
                                    codeBIC
            numCompte
                        codeGuichet
                        codeBanque
                        cleRIB
                        
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
        throw RequestMessage.failgettingDataMessage;
      },
    );
    Bilan? bilan;
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']["bilan"];

      if (data != null) {
        bilan = Bilan.fromJson(data);
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return bilan;
  }

  static Future<dynamic> getOutputs() async {
    var body = '''
               query FluxFinanciers {
                  fluxFinanciers(type: output) {
                      _id
                      libelle
                      type
                      factureId
                      montant
                      reference
                      isFromSystem
                      referenceTransaction
                      status
                      client {
                        _id
                        ... on ClientMoral {
                            _id
                            raisonSociale
                        }
                        ... on ClientPhysique {
                            _id
                            nom
                            prenom
                        }
                    }
                      user {
                        _id
                        personnel {
                            _id
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
                            _id
                            personnel {
                                _id
                                prenom
                                nom
                            }
                        }
                        commentaire
                    }
                   
                      moyenPayement{
                      _id
                      libelle
                      type
                      }
                      pieceJustificative
                      dateOperation
                      bank {
            _id
            name
            type
            codeGuichet
            codeBanque
                        codeBIC
            numCompte
            cleRIB
            soldeReel
            soldeTheorique
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
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.failgettingDataMessage;
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['fluxFinanciers'];

      List<FluxFinancierModel> fluxFinanciers = [];
      if (data != null) {
        for (var fluxFinancier in data) {
          fluxFinanciers.add(FluxFinancierModel.fromJson(fluxFinancier));
        }
        return fluxFinanciers;
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<List<YearsBilan>> getYearsBilan({int? year}) async {
    var body = '''
               query YearBilan {
                  yearBilan(year: $year) {
                      mois
                      input
                      output
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

    List<YearsBilan> yearBilans = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['yearBilan'];

      if (data != null) {
        for (var bilan in data) {
          try {
            yearBilans.add(YearsBilan.fromJson(bilan));
          } catch (e) {
            throw RequestMessage.failgettingDataMessage;
          }
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return yearBilans;
  }
}
