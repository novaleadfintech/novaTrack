import 'dart:convert';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';

import '../model/bulletin_paie/categorie_bulletin.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class CategorieBulletinService {
  static Future<List<CategorieBulletinModel>> getCategoriesBulletin() async {
    var body = '''
      query CategoriesBulletin {
    categoriesBulletin {
        _id
        categorieBulletin
        paieClause
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
      var data = jsonData['data']['categoriesBulletin'];

      List<CategorieBulletinModel> categoriebulletins = [];
      if (data != null) {
        for (var category in data) {
          categoriebulletins.add(CategorieBulletinModel.fromJson(category));
        }
        return categoriebulletins;
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<RequestResponse> createCategorieBulletin({
    required String categorieBulletin,
    required PaieClause paieClause,
  }) async {
    var body = '''
      mutation CreateCategorieBulletin {
    createCategorieBulletin(categorieBulletin: "$categorieBulletin",
    paieClause: ${PaieClause.paieClauseToString(paieClause)}
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
        var data = jsonData['data']['createCategorieBulletin'];
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

  static Future<RequestResponse> updateCategorieBulletin(
      {required String categorieBulletin,
      required String key,
      required PaieClause paieClause}) async {
    var body = '''
mutation UpdateCategorieBulletin {
    updateCategorieBulletin(key: "$key", categorieBulletin: "$categorieBulletin", paieClause: ${PaieClause.paieClauseToString(paieClause)})
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
        var data = jsonData['data']['updateCategorieBulletin'];
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

  static Future<RequestResponse> deleteCategorieBulletin({
    required String key,
  }) async {
    var body = '''
      mutation DeleteCategorieBulletin {
    deleteCategorieBulletin(key: "$key")
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
        var data = jsonData['data']['deleteCategorieBulletin'];
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
