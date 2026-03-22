import 'dart:convert';
import 'package:frontend/model/bulletin_paie/categorie_bulletin.dart';
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
      getBulletinRubriquesByCategorieBulletinForConfig(
          {required CategorieBulletinModel categorieBulletin}) async {
    var body = '''
      query RubriqueBulletinByCategorieBulletinForConfiguration {
    rubriqueBulletinByCategorieBulletinForConfiguration(categorieBulletinId: "${categorieBulletin.id}") {
        isChecked
        rubriqueOnBulletin {
            value
            rubrique{
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
            reference{
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
          ['rubriqueBulletinByCategorieBulletinForConfiguration'];
      List<RubriquePaieConfig> rubriques = [];
      if (data != null) {
        for (var rubrique in data) {
          try {
            rubriques.add(RubriquePaieConfig.fromJson(rubrique));
          } catch (e) {
            print('Error parsing rubrique: $e');
          }
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
      getBulletinRubriquesByCategorieBulletin(
          {required CategorieBulletinModel categorieBulletin}) async {
    var body = '''
    query RubriqueBulletinByCategorieBulletin {
    rubriqueBulletinByCategorieBulletin(categorieBulletinId: "${categorieBulletin.id}") {
    value
         rubrique{
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
            reference{
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
      var data = jsonData['data']['rubriqueBulletinByCategorieBulletin'];
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
          {required CategorieBulletinModel categorieBulletin,
          required String salarieId}) async {
    var body = '''
    query variablePaieAndPrimeExceptionnelles {
    variablePaieAndPrimeExceptionnelles(categorieBulletinId: "${categorieBulletin.id}", salarieId: "$salarieId") {
      salarieId
      _id
      rubriques{
        value
        rubrique{
           _id
        rubrique
        code
        type
        portee
        rubriqueRole
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
            reference{
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
      primesExceptionnelles{
        value
        rubrique{
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
            reference{
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

  static Future<RequestResponse> createCategorieBulletinRubrique({
    required String rubriqueId,
    required String categorieBulletinId,
    required double? value,
  }) async {
    var body = '''
    mutation {
      createCategorieBulletinRubrique(
        rubriqueId: "$rubriqueId",
        categorieBulletinId: "$categorieBulletinId",
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
            ['createCategorieBulletinRubrique'];
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

  static Future<RequestResponse> updateCategorieBulletinRubriqueBulletin({
    required String rubriqueId,
    required String categorieBulletinId,
    required double? value,
  }) async {
    var body = '''
    mutation {
      updateCategorieBulletinRubrique(
        rubriqueId: "$rubriqueId",
        categorieBulletinId: "$categorieBulletinId",
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
            ['updateCategorieBulletinRubriqueBulletin'];
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

  static Future<RequestResponse> deleteCategorieBulletinRubriqueBulletin({
    required String rubriqueId,
    required String categorieBulletinId,
  }) async {
    var body = '''
    mutation {
      deleteCategorieBulletinRubrique(
        rubriqueId: "$rubriqueId",
        categorieBulletinId: "$categorieBulletinId"
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
            ['deleteCategorieBulletinRubriqueBulletin'];
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
