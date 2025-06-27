import 'dart:convert';

import 'package:flutter/material.dart';

import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/flux_financier/creance_model.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class CreanceService {
  //final client = TokenClient(AuthService().getToken(), http.Client());
  static Future<List<CreanceModel>> getCreanceTobePaidWithDate({
    DateTime? debut,
    DateTime? fin,
  }) async {
    var body = '''
              query CreancesTobePay {
                  creancesTobePay''';
    if (debut != null && fin != null) {
      body +=
          '(begin: ${debut.millisecondsSinceEpoch}, end: ${fin.millisecondsSinceEpoch})';
    }
    body += ''' {
                     
                      montantRestant
                      factures {
                          _id
                          reference
                          montant
                          type
                          payements {
                              _id
                              montant
                          }
                        facturesAcompte {
                        rang
                        pourcentage
                        datePayementEcheante
                        isPaid
                    }
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
                  }
                  
              }

            ''';
    var response = await http.post(
      Uri.parse(serverUrl),
      body: json.encode({
        'query': body,
      }),
   headers: getHeaders(),
    ).catchError((onError) {
      throw RequestMessage.onCatchErrorMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );
    List<CreanceModel> creances = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['creancesTobePay'];

      if (data != null) {
        for (var creance in data) {
          creances.add(CreanceModel.fromJson(creance));
        }
      } else {
        throw RequestMessage.successwithbugMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return creances;
  }

  static Future<List<CreanceModel>> getPassCreanceWithDate({
    DateTime? debut,
    DateTime? fin,
  }) async {
    var body = '''
              query UnpaidCreances {
                  unpaidCreances''';
    if (debut != null && fin != null) {
      body +=
          '(begin: ${debut.millisecondsSinceEpoch}, end: ${fin.millisecondsSinceEpoch})';
    }
    body += ''' {
                      montantRestant
                      factures {
                          _id
                          reference
                          montant
                          type
                          payements {
                              _id
                              montant
                          }
                        
                          facturesAcompte {
                        rang
                        pourcentage
                        datePayementEcheante
                        isPaid
                    }
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
                  }
              }

            ''';
    var response = await http.post(
      Uri.parse(serverUrl),
      body: json.encode({
        'query': body,
      }),
headers: getHeaders(),
    ).catchError((onError) {
      throw RequestMessage.onCatchErrorMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );
    List<CreanceModel> creances = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['unpaidCreances'];
      if (data != null) {
        for (var creance in data) {
          try {
            creances.add(CreanceModel.fromJson(creance));
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      } else {
        throw RequestMessage.successwithbugMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return creances;
  }

  static Future<List<CreanceModel>> getClaimAmount({
    DateTime? debut,
    DateTime? fin,
  }) async {
    var body = '''
              query GetDailyClaim {
                  getDailyClaim{
                      montantRestant
                  }
              }
            ''';
    var response = await http.post(
      Uri.parse(serverUrl),
      body: json.encode({
        'query': body,
      }),
headers: getHeaders(),
    ).catchError((onError) {
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );
    List<CreanceModel> creances = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['getDailyClaim'];
      if (data != null) {
        for (var creance in data) {
          creances.add(CreanceModel.fromJson(creance));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return creances;
  }
}
