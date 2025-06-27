import 'dart:convert';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/bulletin_paie/categorie_paie.dart';
import '../model/bulletin_paie/rubrique_paie.dart';
import '../model/request_response.dart';
import 'request_header.dart';
import 'package:http/http.dart' as http;

class RubriqueCategorieConfService {
  static Future<List<RubriquePaieConfig>>
      getBulletinRubriquesByCategorieForConfig(
          {required CategoriePaieModel categoriePaie}) async {
    var body = '''
      query RubriqueBulletinByCategoriePaieForConfiguration {
    rubriqueBulletinByCategoriePaieForConfiguration(categoriePaieId: "${categoriePaie.id}") {
        isChecked
        rubriqueCategorie {
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
      var data =
          jsonData['data']['rubriqueBulletinByCategoriePaieForConfiguration'];

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
      getBulletinRubriquesByCategoriePaie(
          {required CategoriePaieModel categorie}) async {
    var body = '''
    query RubriqueBulletinByCategoriePaie {
    rubriqueBulletinByCategoriePaie(categoriePaieId: "${categorie.id}") {
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
       var data = jsonData['data']['rubriqueBulletinByCategoriePaie'];
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

  static Future<RequestResponse> createRubriqueCategorie({
    required String rubriqueId,
    required String categorieId,
    required double? value,
  }) async {
    var body = '''
    mutation {
      createRubriqueCategorie(
        rubriqueId: "$rubriqueId",
        categorieId: "$categorieId",
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
        final data =
            jsonDecode(response.body)['data']['createRubriqueCategorie'];
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

  static Future<RequestResponse> updateRubriqueCategorie({
    required String rubriqueId,
    required String categorieId,
    required double? value,
  }) async {
    var body = '''
    mutation {
      updateRubriqueCategorie(
        rubriqueId: "$rubriqueId",
        categorieId: "$categorieId",
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
        final data =
            jsonDecode(response.body)['data']['updateRubriqueCategorie'];
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

  static Future<RequestResponse> deleteRubriqueCategorie({
    required String rubriqueId,
    required String categorieId,
  }) async {
    var body = '''
    mutation {
      deleteRubriqueCategorie(
        rubriqueId: "$rubriqueId",
        categorieId: "$categorieId"
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
        final data =
            jsonDecode(response.body)['data']['deleteRubriqueCategorie'];
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
