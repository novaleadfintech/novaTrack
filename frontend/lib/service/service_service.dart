import 'dart:convert';

import 'package:frontend/model/pays_model.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/service/enum_service.dart';
import '../model/service/service_model.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import '../model/service/service_prix_model.dart';
import 'request_header.dart';

class ServiceService {
  static Future<List<ServiceModel>> getArchivedService() async {
    var body = '''
                query Services {
                  services(etat: archived) {
                    _id
                    libelle
                    tarif {
                        minQuantity
                        maxQuantity
                        prix
                    }
                    nature
                    prix
                    country {
                        _id
                        name
                        code
                      }
                    type
                    etat
                    description
                    fullCount
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
    List<ServiceModel> services = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['services'];

      if (data != null) {
        for (var service in data) {
          services.add(ServiceModel.fromJson(service));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return services;
  }

  static Future<List<ServiceModel>> getUnarchivedService() async {
    var body = '''
                query Services {
                  services(etat: unarchived) {
                    _id
                    libelle
                    tarif {
                        minQuantity
                        maxQuantity
                        prix
                    }
                    prix
                    country {
                        _id
                        name
                        code
                      }
                    type
                    etat
                    nature
                    description
                    fullCount
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

    List<ServiceModel> services = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['services'];
      if (data != null) {
        for (var service in data) {
          services.add(ServiceModel.fromJson(service));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return services;
  }

  static Future<RequestResponse> createService({
    required String libelle,
    required double? prix,
    required List<ServiceTarifModel>? tarif,
    required ServiceType type,
    required NatureService nature,
    String? description,
    required PaysModel country,
  }) async {
    var body = '''
    mutation CreateService {
      createService(
        libelle: "$libelle",
       country: ${country.toJson()},
        type: ${serviceTypeToString(type)},
        nature: ${natureServiceToString(nature)},
        ''';

    if (tarif != null && tarif.isNotEmpty) {
      body += 'tarif: [';
      for (var pr in tarif) {
        body +=
            '{minQuantity: ${pr.minQuantity}, prix: ${pr.prix}, maxQuantity: ${pr.maxQuantity}}';
      }
      body += '],';
    }

    if (prix != null) {
      body += 'prix: $prix,';
    }

    if (description != null) {
      body += 'description: "$description",';
    }
    body += '''
      )
    }
  ''';
    print(body);
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
        var data = jsonData['data']['createService'];
        if (data == RequestMessage.success) {
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

  static Future<RequestResponse> updateService({
    required String serviceId,
    required String? libelle,
    required double? prix,
    required List<ServiceTarifModel>? tarif,
    required ServiceType? type,
    required NatureService? nature,
    required PaysModel? country,
    required String? description,
  }) async {
    var body = '''
        mutation UpdateService {
          updateService(
            key: "$serviceId",
    ''';

    if (libelle != null) {
      body += 'libelle: "$libelle",';
    }
    if (prix != null) {
      body += 'prix: $prix,';
    }
    if (description != null) {
      body += 'description: "$description",';
    }
    if (type != null) {
      body += 'type: ${serviceTypeToString(type)},';
    }
    if (nature != null) {
      body += 'nature: ${natureServiceToString(nature)},';
    }
    if (country != null) {
      body += 'country: ${country.toJson()},';
    }
    if (tarif != null) {
      body += 'tarif: [';
      for (var pr in tarif) {
        body +=
            '{minQuantity: ${pr.minQuantity}, prix: ${pr.prix}, maxQuantity: ${pr.maxQuantity}},';
      }
      body += '],';
    }
    body += '''
      ) }
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

      // Gestion de la réponse
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateService'];
        if (data != null) {
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
        message: RequestMessage.onCatchErrorMessage,
        status: PopupStatus.serverError,
      );
    }
  }

  static Future<RequestResponse> archivedService({
    required String serviceId,
  }) async {
    var body = '''
    mutation ArchivedService {
      archivedService(key: "$serviceId")
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
        var data = jsonData['data']['archivedService'];
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

  static Future<RequestResponse> unarchivedService({
    required String serviceId,
  }) async {
    var body = '''
      mutation UnarchivedService {
        unarchivedService(key: "$serviceId")
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
        var data = jsonData['data']['unarchivedService'];
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
}
