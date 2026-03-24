import 'dart:convert';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/client/categorie_model.dart';

import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class CategorieService {
  static Future<List<CategorieModel>> getCategories() async {
    var body = '''
      query partnerCategories {
        partnerCategories {
            _key
            libelle
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
      throw onError;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.failgettingDataMessage;
      },
    );
    try {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['partnerCategories'];
        List<CategorieModel> partnerCategories = [];
        if (data != null) {
          for (var category in data) {
            partnerCategories.add(CategorieModel.fromJson(category));
          }
          return partnerCategories;
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

  // Méthode pour créer une nouvelle catégorie
  static Future<RequestResponse> createPartnerCategorie({
    required String libelle,
    String? description,
  }) async {
    var body = '''
      mutation CreatePartnerCategorie {
        createPartnerCategorie(
          libelle: "$libelle",
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
        var data = jsonData['data']['createPartnerCategorie'];
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

  static Future<RequestResponse> updatePartnerCategorie({
    required String key,
    required String libelle,
    String? description,
  }) async {
    var body = '''
      mutation UpdatepaieCategorie {
    updatePartnerCategorie(key: "$key", libelle: "$libelle")
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
        var data = jsonData['data']['updatePartnerCategorie'];
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

  static Future<RequestResponse> deletePartnerCategorie({
    required String key,
  }) async {
    var body = '''
      mutation DeleteCateforie {
        deleteCateforie(key: "$key")
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
        var data = jsonData['data']['deleteCateforie'];
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
