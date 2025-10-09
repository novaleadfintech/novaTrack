import 'dart:convert';
import 'package:frontend/model/grille_salariale/echelon_model.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';

import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class EchelonService {
  static Future<List<EchelonModel>> getEchelons() async {
    var body = '''
      query Echelons {
        echelons {
          _id
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
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.failgettingDataMessage;
      },
    );

    List<EchelonModel> echelons = [];

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['echelons'];
      if (data != null) {
        for (var echelon in data) {
          echelons.add(EchelonModel.fromJson(echelon));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return echelons;
  }

  static Future<RequestResponse> createEchelon({
    required String libelle,
  }) async {
    var body = '''
    mutation CreateEchelon {
    createEchelon(libelle: "$libelle")
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
        var data = jsonData['data']['createEchelon'];
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
      throw error.toString();
    }
  }

  static Future<RequestResponse> updateEchelon({
    required String key,
    required String echelon,
  }) async {
    var body = '''
     mutation UpdateEchelon {
    updateEchelon(key: "$key", echelon: "$echelon")
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
        var data = jsonData['data']['updateEchelon'];
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
      throw RequestMessage.onCatchErrorMessage;
    }
  }

  static Future<RequestResponse> deleteEchelon({
    required String key,
  }) async {
    var body = '''
     mutation DeleteEchelon {
    deleteEchelon(key: "$key")
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
        var data = jsonData['data']['deleteEchelon'];
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
      throw RequestMessage.onCatchErrorMessage;
    }
  }
}
