import 'dart:convert';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';

import '../model/bulletin_paie/bulletin_categorie.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class BulletinCategorieservice {
  static Future<List<BulletinCategorieModel>> getBulletinCategories() async {
    var body = '''
      query BulletinCategories {
    bulletinCategories {
        _key
        bulletinCategorie
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
       var data = jsonData['data']['bulletinCategories'];

      List<BulletinCategorieModel> bulletincategories = [];
      if (data != null) {
        for (var category in data) {
          bulletincategories.add(BulletinCategorieModel.fromJson(category));
        }
        return bulletincategories;
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<RequestResponse> createBulletinCategorie({
    required String bulletinCategorie,
    required PaieClause paieClause,
  }) async {
    var body = '''
      mutation CreateBulletinCategorie {
    createBulletinCategorie(bulletinCategorie: "$bulletinCategorie",
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
        var data = jsonData['data']['createBulletinCategorie'];
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

  static Future<RequestResponse> updateBulletinCategorie(
      {required String bulletinCategorie,
      required String key,
      required PaieClause paieClause}) async {
    var body = '''
mutation UpdateBulletinCategorie {
    updateBulletinCategorie(key: "$key", bulletinCategorie: "$bulletinCategorie", paieClause: ${PaieClause.paieClauseToString(paieClause)})
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
        var data = jsonData['data']['updateBulletinCategorie'];
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

  static Future<RequestResponse> deleteBulletinCategorie({
    required String key,
  }) async {
    var body = '''
      mutation DeleteBulletinCategorie {
    deleteBulletinCategorie(key: "$key")
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
        var data = jsonData['data']['deleteBulletinCategorie'];
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
