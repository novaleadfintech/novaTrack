import 'dart:convert';
import 'package:frontend/model/bulletin_paie/nature_rubrique.dart';
import 'package:frontend/model/bulletin_paie/rubrique.dart';
import 'package:frontend/model/bulletin_paie/section_bulletin.dart';
import 'package:frontend/model/bulletin_paie/type_rubrique.dart';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/bulletin_paie/tranche_model.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;
import 'request_header.dart';

class BulletinRubriqueService {
  static Future<List<RubriqueBulletin>> getBulletinRubriques() async {
    var body = '''
      query RubriquesBulletin {
    rubriquesBulletin {
        _id
        rubrique
        code
        type
        nature
        portee
        rubriqueRole
        rubriqueIdentity
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
      var data = jsonData['data']['rubriquesBulletin'];

      List<RubriqueBulletin> rubriques = [];
      if (data != null) {
        // print(data);

        for (var rubrique in data) {
          rubriques.add(RubriqueBulletin.fromJson(rubrique));
        }

        return rubriques;
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<RequestResponse> createBulletinRubrique({
    required String rubrique,
    required String code,
    required NatureRubrique nature,
    required PorteeRubrique? portee,
    required TypeRubrique? type,
    required RubriqueRole? rubriqueRole,
    required SectionBulletin? section,
    required Taux? taux,
    required Bareme? bareme,
    required RubriqueIdentity? rubriqueIdentity,
    required Calcul? sommeRubrique,
    required Calcul? calcul,
  }) async {
    var body = '''
     mutation CreateRubriqueBulletin {
        createRubriqueBulletin(
            rubrique: "$rubrique",
            code: "$code",
            portee: ${portee == null ? null : porteeRubriqueToString(portee)}
            nature: ${natureRubriqueToString(nature)},
            type: ${type == null ? null : typeRubriqueToString(type)},
            sectionId: ${section == null ? null : "\"${section.id}\""},
            bareme: ${bareme?.toJson()},
            taux: ${taux?.toJson()},
            rubriqueIdentity: ${rubriqueIdentity == null ? null : constantIdentityToString(rubriqueIdentity)}
            rubriqueRole: ${rubriqueRole == null ? null : rubriqueRoleToString(rubriqueRole)},
            sommeRubrique: ${sommeRubrique?.toJson()},
            calcul: ${calcul?.toJson()},
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
          .timeout(const Duration(seconds: reqTimeout), onTimeout: () {
        throw RequestMessage.timeoutMessage;
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createRubriqueBulletin'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.serverErrorMessage,
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

  static Future<RequestResponse> updateBulletinRubrique({
    required String key,
    required String? rubrique,
    required NatureRubrique? nature,
    required PorteeRubrique? portee,
    required TypeRubrique? type,
    required RubriqueRole? rubriqueRole,
    required SectionBulletin? section,
    required Taux? taux,
    required Bareme? bareme,
    required RubriqueIdentity? rubriqueIdentity,
    required Calcul? sommeRubrique,
    required Calcul? calcul,
  }) async {
 
    var body = '''
      mutation UpdateRubriqueBulletin {
          updateRubriqueBulletin(
              key: "$key"
              rubrique: "$rubrique",
              portee: ${portee == null ? null : porteeRubriqueToString(portee)}
              nature: ${nature == null ? null : natureRubriqueToString(nature)},
              type: ${type == null ? null : typeRubriqueToString(type)},
              sectionId: ${section == null ? null : "\"${section.id}\""},
              bareme: ${bareme?.toJson()},
              taux: ${taux?.toJson()},
              rubriqueIdentity: ${rubriqueIdentity == null ? null : constantIdentityToString(rubriqueIdentity)}
              rubriqueRole: ${rubriqueRole == null ? null : rubriqueRoleToString(rubriqueRole)},
              sommeRubrique: ${sommeRubrique?.toJson()},
              calcul: ${calcul?.toJson()},
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
          .timeout(const Duration(seconds: reqTimeout), onTimeout: () {
        throw RequestMessage.timeoutMessage;
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateRubriqueBulletin'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.serverErrorMessage,
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

  static Future<RequestResponse> deleteBulletinRubrique({
    required String key,
  }) async {
    var body = '''
      mutation DeleteBulletinRubrique {
    deleteBulletinRubrique(key: "$key")
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
        var data = jsonData['data']['deleteBulletinRubrique'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.serverErrorMessage,
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
}
