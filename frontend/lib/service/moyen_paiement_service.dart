import 'dart:convert';
import 'package:frontend/model/flux_financier/type_flux_financier.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';

import '../model/entreprise/type_canaux_paiement.dart';
import '../model/moyen_paiement_model.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class MoyenPaiementService {
  static Future<List<MoyenPaiementModel>> getMoyenPaiements(
      {FluxFinancierType? type}) async {
    var body = '''
      query MoyensPaiement {
    moyensPaiement {
        _id
        libelle
        type
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
    List<MoyenPaiementModel> moyensPaiement = [];

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['moyensPaiement'];
      if (data != null) {
        for (var libelle in data) {
          moyensPaiement.add(MoyenPaiementModel.fromJson(libelle));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return moyensPaiement;
  }

  static Future<RequestResponse> createMoyenPaiement({
    required String libelle,
    required CanauxPaiement type,
  }) async {
    var body = '''
     mutation CreateMoyenPaiement {
    createMoyenPaiement(libelle: "$libelle", type: ${canauxPaiementToString(type)}
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
        var data = jsonData['data']['createMoyenPaiement'];
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

  static Future<RequestResponse> updateMoyenPaiement({
    required String key,
    required String? libelle,
    required CanauxPaiement? type,
  }) async {
    var body = '''
      mutation UpdateMoyenPaiement {
        updateMoyenPaiement(
        key: "$key",
        ''';
    if (libelle != null) {
      body += ' libelle: "$libelle",';
    }
    if (type != null) {
      body += 'type: ${canauxPaiementToString(type)}';
    }
    body += '''
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
        var data = jsonData['data']['updateMoyenPaiement'];
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

  static Future<RequestResponse> deleteMoyenPaiement({
    required String key,
  }) async {
    var body = '''
      mutation DeleteMoyenPaiement {
        deleteMoyenPaiement(key: "$key")
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
        var data = jsonData['data']['deleteMoyenPaiement'];
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
