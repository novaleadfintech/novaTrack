import 'dart:convert';
import 'package:frontend/model/bulletin_paie/bulletin_categorie_model.dart';
import 'package:frontend/model/bulletin_paie/valeur_rubrique_temporaire.dart';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/bulletin_paie/rubrique_paie.dart';
import '../model/request_response.dart';
import 'request_header.dart';
import 'package:http/http.dart' as http;

class RubriqueCategorieConfService {
  static Future<List<RubriquePaieConfig>>
      getBulletinRubriquesByBulletinCategorieForConfig(
          {required BulletinCategorieModel bulletinCategorie}) async {
    var body = '''
      query RubriqueBulletinByBulletinCategorieForConfiguration {
    rubriqueBulletinByBulletinCategorieForConfiguration(bulletinCategorieKey: "${bulletinCategorie.key}") {
        isChecked
        rubriqueOnBulletin {
            value
            rubrique{
           _key
        rubrique
        code
        type
        portee
        rubriqueIdentity
        nature
        section {
            _key
            section
        }
        taux {
            base {
                _key
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
                    _key
                    rubrique
                    code
                    type
                    nature
                }
            }
        }
        bareme {
            reference{
                _key
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
                            _key
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
                    _key
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
}    ''';

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

      var data = jsonData['data']
          ['rubriqueBulletinByBulletinCategorieForConfiguration'];
      List<RubriquePaieConfig> rubriques = [];
      if (data != null) {
        for (var rubrique in data) {

            rubriques.add(RubriquePaieConfig.fromJson(rubrique));
 
        }
        return rubriques;
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<List<RubriqueOnBulletinModel>>
      getBulletinRubriquesByBulletinCategorie(
          {required BulletinCategorieModel bulletinCategorie}) async {
    var body = '''
    query RubriqueBulletinByBulletinCategorie {
    rubriqueBulletinByBulletinCategorie(bulletinCategorieKey: "${bulletinCategorie.key}") {
    value
         rubrique{
           _key
        rubrique
        code
        type
        portee
        rubriqueIdentity
        nature
        section {
            _key
            section
        }
        taux {
            base {
                _key
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
                    _key
                    rubrique
                    code
                    type
                    nature
                }
            }
        }
        bareme {
            reference{
                _key
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
                            _key
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
                    _key
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
      var data = jsonData['data']['rubriqueBulletinByBulletinCategorie'];
      List<RubriqueOnBulletinModel> rubriques = [];
      if (data != null) {
        for (var rubrique in data) {
          rubriques.add(RubriqueOnBulletinModel.fromJson(rubrique));
        }

        return rubriques;
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<ValeurRubriqueTemporaire>
      getvariablePaieAndPrimeExceptionnelles(
          {required BulletinCategorieModel bulletinCategorie,
          required String salarieKey}) async {
    var body = '''
    query variablePaieAndPrimeExceptionnelles {
    variablePaieAndPrimeExceptionnelles(bulletinCategorieKey: "${bulletinCategorie.key}", salarieKey: "$salarieKey") {
      salarieKey
      _key
      rubriques{
        value
        rubrique{
           _key
        rubrique
        code
        type
        portee
        rubriqueRole
        rubriqueIdentity
        nature
        section {
            _key
            section
        }
        taux {
            base {
                _key
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
                    _key
                    rubrique
                    code
                    type
                    nature
                }
            }
        }
        bareme {
            reference{
                _key
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
                            _key
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
                    _key
                    rubrique
                    code
                    type
                    nature
                }
            }
        }
         }
      }
      primesExceptionnelles{
        value
        rubrique{
           _key
        rubrique
        code
        type
        portee
        rubriqueIdentity
        nature
        section {
            _key
            section
        }
        taux {
            base {
                _key
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
                    _key
                    rubrique
                    code
                    type
                    nature
                }
            }
        }
        bareme {
            reference{
                _key
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
                            _key
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
                    _key
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

    try {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['variablePaieAndPrimeExceptionnelles'];
        if (data != null) {
          return ValeurRubriqueTemporaire.fromJson(data);
        } else {
          throw RequestMessage.failgettingDataMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<RequestResponse> createBulletinCategorieRubrique({
    required String rubriqueKey,
    required String bulletinCategorieKey,
    required double? value,
  }) async {
    var body = '''
    mutation {
      createBulletinCategorieRubrique(
        rubriqueKey: "$rubriqueKey",
        bulletinCategorieKey: "$bulletinCategorieKey",
        value: $value
      )
    }
  ''';

    try {
      final response = await http
          .post(
            Uri.parse(serverUrl),
            body: json.encode({'query': body}),
            headers: getHeaders(),
          )
          .timeout(
            const Duration(seconds: reqTimeout),
            onTimeout: () => throw RequestMessage.timeoutMessage,
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']
            ['createBulletinCategorieRubrique'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          throw RequestMessage.serverErrorMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      return RequestResponse(
        message: error.toString(),
        status: PopupStatus.serverError,
      );
    }
  }

  static Future<RequestResponse> updateBulletinCategorieRubriqueBulletin({
    required String rubriqueKey,
    required String bulletinCategorieKey,
    required double? value,
  }) async {
    var body = '''
    mutation {
      updateBulletinCategorieRubrique(
        rubriqueKey: "$rubriqueKey",
        bulletinCategorieKey: "$bulletinCategorieKey",
        value: $value
      )
    }
  ''';

    try {
      final response = await http
          .post(
            Uri.parse(serverUrl),
            body: json.encode({'query': body}),
            headers: getHeaders(),
          )
          .timeout(
            const Duration(seconds: reqTimeout),
            onTimeout: () => throw RequestMessage.timeoutMessage,
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']
            ['updateBulletinCategorieRubriqueBulletin'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          throw RequestMessage.serverErrorMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      return RequestResponse(
        message: error.toString(),
        status: PopupStatus.serverError,
      );
    }
  }

  static Future<RequestResponse> deleteBulletinCategorieRubriqueBulletin({
    required String rubriqueKey,
    required String bulletinCategorieKey,
  }) async {
    var body = '''
    mutation {
      deleteBulletinCategorieRubrique(
        rubriqueKey: "$rubriqueKey",
        bulletinCategorieKey: "$bulletinCategorieKey"
      )
    }
  ''';

    try {
      final response = await http
          .post(
            Uri.parse(serverUrl),
            body: json.encode({'query': body}),
            headers: getHeaders(),
          )
          .timeout(
            const Duration(seconds: reqTimeout),
            onTimeout: () => throw RequestMessage.timeoutMessage,
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']
            ['deleteBulletinCategorieRubriqueBulletin'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          throw RequestMessage.serverErrorMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      return RequestResponse(
        message: error.toString(),
        status: PopupStatus.serverError,
      );
    }
  }
}
