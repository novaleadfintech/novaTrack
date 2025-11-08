import 'dart:convert';
import 'package:frontend/model/bulletin_paie/categorie_paie.dart';
import 'package:frontend/model/bulletin_paie/rubrique_paie.dart';
import 'package:frontend/model/bulletin_paie/salarie_model.dart';
import 'package:frontend/model/bulletin_paie/valeur_rubrique_temporaire.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class ValariablePaieService {
  static Future<RequestResponse> createValariablePaie({
    required SalarieModel salarie,
    required List<RubriqueOnBulletinModel> variablePaie,
    required List<RubriqueOnBulletinModel> primesExceptionnelles,
  }) async {
    // Construction du champ "rubriques"
    final rubriquesString = variablePaie.map((r) {
      final rubriqueId = r.rubrique.id;
      final value = r.value ?? 0;

      return '''
      {
        rubriqueId: "$rubriqueId",
        value: $value
      }
    ''';
    }).join(',');


    final primeExceptionnelleString = primesExceptionnelles.map((r) {
      final rubriqueId = r.rubrique.id;
      final value = r.value ?? 0;

      return '''
      {
        rubriqueId: "$rubriqueId",
        value: $value
      }
    ''';
    }).join(',');

    // Corps complet de la mutation
    final body = '''
    mutation CreateValeurRubriqueTemporaire {
      createValeurRubriqueTemporaire(
        salarieId: "${salarie.id}",
        rubriques: [$rubriquesString]
        primesExceptionnelles: [$primeExceptionnelleString]
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
            status: PopupStatus.customError,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createValeurRubriqueTemporaire'];
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
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }


static Future<List<ValeurRubriqueTemporaire>>
      getvariablePaieAndPrimeExceptionnelles(
          {required CategoriePaieModel categorie,
          required String salarieId}) async {
    var body = '''
    query variablePaieAndPrimeExceptionnelles {
        variablePaieAndPrimeExceptionnelles(
            categoriePaieId: "${categorie.id}"
            salarieId: "$salarieId"
        ) {
            salarieId
            rubriques {
                value
                rubrique {
                    _id
                    rubrique
                    code
                    type
                    portee
                    rubriqueIdentity
                    nature
                    section {
                        _id
                        section
                    }
                    taux {
                        base {
                            _id
                            rubrique
                            code
                            type
                            nature
                        }
                        taux
                    }
                    sommeRubrique {
                        operateur
                        elements {
                            type
                            valeur
                            rubrique {
                                _id
                                rubrique
                                code
                                type
                                nature
                            }
                        }
                    }
                    bareme {
                        reference {
                            _id
                            rubrique
                            code
                            type
                            nature
                        }
                        tranches {
                            min
                            max
                            value {
                                type
                                valeur
                                taux {
                                    base {
                                        _id
                                        rubrique
                                        code
                                        type
                                        nature
                                    }
                                    taux
                                }
                            }
                        }
                    }
                    calcul {
                        operateur
                        elements {
                            type
                            valeur
                            rubrique {
                                _id
                                rubrique
                                code
                                type
                                nature
                            }
                        }
                    }
                }
            }
            primesExceptionnelles {
                value
                rubrique {
                    _id
                    rubrique
                    code
                    type
                    portee
                    rubriqueIdentity
                    nature
                    section {
                        _id
                        section
                    }
                    taux {
                        base {
                            _id
                            rubrique
                            code
                            type
                            nature
                        }
                        taux
                    }
                    sommeRubrique {
                        operateur
                        elements {
                            type
                            valeur
                            rubrique {
                                _id
                                rubrique
                                code
                                type
                                nature
                            }
                        }
                    }
                    bareme {
                        reference {
                            _id
                            rubrique
                            code
                            type
                            nature
                        }
                        tranches {
                            min
                            max
                            value {
                                type
                                valeur
                                taux {
                                    base {
                                        _id
                                        rubrique
                                        code
                                        type
                                        nature
                                    }
                                    taux
                                }
                            }
                        }
                    }
                    calcul {
                        operateur
                        elements {
                            type
                            valeur
                            rubrique {
                                _id
                                rubrique
                                code
                                type
                                nature
                            }
                        }
                    }
                }
            }
        }
    }
    ''';

    var response = await http
        .post(
      Uri.parse(serverUrl),
      body: json.encode({'query': body}),
      headers: getHeaders(),
    )
        .catchError((onError) {
      throw onError.toString();
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['variablePaieAndPrimeExceptionnelles'];
      List<ValeurRubriqueTemporaire> rubriques = [];
      if (data != null) {
        for (var rubrique in data) {
          rubriques.add(ValeurRubriqueTemporaire.fromJson(rubrique));
        }

        return rubriques;
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }


  static Future<RequestResponse> updateValariablePaie({
    required String paysId,
    String? nom,
    double? taux,
    int? nbreNumTel,
    required List<int> initiauxValariablePaie,
    int? code,
  }) async {
    var body = StringBuffer('''
    mutation UpdateCountry {
      updateCountry(
        key: "$paysId",
  ''');

    if (nom != null) {
      body.write('name: "$nom",');
    }
    if (taux != null) {
      body.write('tauxTVA: $taux,');
    }
    if (nbreNumTel != null) {
      body.write('phoneNumber: $nbreNumTel,');
    }
    if (code != null) {
      body.write('code: $code,');
    }
    if (initiauxValariablePaie.isNotEmpty) {
      body.write('initiauxValariablePaie: ${initiauxValariablePaie.toList()},');
    }

    body.write(') }');

    try {
      var response = await http
          .post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body.toString()}),
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

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateCountry'];

        if (data != null) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.customError,
          );
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }
}
