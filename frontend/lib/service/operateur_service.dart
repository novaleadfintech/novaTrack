import 'dart:convert';
import 'package:frontend/model/bulletin_paie/operateur_model.dart';
 import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class OperateurService {
  static Future<List<OperateurModel>> getOperateurs() async {
    var body = '''
      query Operateurs {
          operateurs {
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
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.failgettingDataMessage;
      },
    );
    List<OperateurModel> operateurs = [];

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['operateurs'];
      if (data != null) {
        for (var operateur in data) {
          operateurs.add(OperateurModel.fromJson(operateur));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return operateurs;
  }

  static Future<RequestResponse> createOperateur({
    required String libelle,
  }) async {
    var body = '''
    mutation CreateOperateur {
    createOperateur(libelle: "$libelle")
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
        var data = jsonData['data']['createOperateur'];
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

  static Future<RequestResponse> updateOperateur({
    required String key,
    required String libelle,
  }) async {
    var body = '''
     mutation UpdateOperateur {
    updateOperateur(key: "$key", libelle: "$libelle")
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
        var data = jsonData['data']['updateOperateur'];
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

  static Future<RequestResponse> deleteOperateur({
    required String key,
  }) async {
    var body = '''
     mutation DeleteOperateur {
    deleteOperateur(key: "$key")
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
        var data = jsonData['data']['deleteOperateur'];
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
