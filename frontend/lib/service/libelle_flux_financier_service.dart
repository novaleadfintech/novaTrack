import 'dart:convert';
import 'package:frontend/model/flux_financier/libelle_flux.dart';
import 'package:frontend/model/flux_financier/type_flux_financier.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';

import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class LibelleFluxFinancierService {
  static Future<List<LibelleFluxModel>> getLibelleFluxFinanciers(
      {FluxFinancierType? type}) async {
    var body = '''
      query LibelleFlux {
      libelleFlux${type != null ? '(type: ${fluxFinancierTypeToString(type)})' : ''} {
        _id
        libelle
        type
      }
    }
    ''';
    var response = await http.post(
      Uri.parse(serverUrl),
      body: json.encode({'query': body}),
headers: getHeaders(),
    ).catchError((onError) {
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.failgettingDataMessage;
      },
    );
    List<LibelleFluxModel> libelleFluxFinanciers = [];

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['libelleFlux'];
      if (data != null) {
        for (var libelle in data) {
          libelleFluxFinanciers.add(LibelleFluxModel.fromJson(libelle));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return libelleFluxFinanciers;
  }

  static Future<RequestResponse> createLibelleFluxFinancier({
    required String libelle,
    required FluxFinancierType type,
  }) async {
    var body = '''
      mutation CreateLibelleFlux {
        createLibelleFlux(
          libelle: "$libelle",
          type: ${fluxFinancierTypeToString(type)},
        )
      }
    ''';

    try {
      var response = await http.post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      ).timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
        throw RequestMessage.timeoutMessage;
      }
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createLibelleFlux'];
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

  static Future<RequestResponse> updateLibelleFluxFinancier({
    required String key,
    required String? libelle,
    required FluxFinancierType? type,
  }) async {
    var body = '''
      mutation UpdateLibelleFlux {
        updateLibelleFlux(
        key: "$key",
         ''';
    if (libelle != null) {
      body += 'libelle: "$libelle",';
    }
    
    if (type != null) {
      body += 'type: "${fluxFinancierTypeToString(type)}",';
    }
    body += '''
        )
      }
    ''';

    try {
      var response = await http.post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      ).timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
        throw RequestMessage.timeoutMessage;
      }
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateLibelleFlux'];
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

  static Future<RequestResponse> deletelibelleFluxFinancier({
    required String key,
  }) async {
    var body = '''
      mutation DeleteLibelleFlux {
        deleteLibelleFlux(key: "$key")
      }
    ''';

    try {
      var response = await http.post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      ).timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
        throw RequestMessage.timeoutMessage;
      }
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['deleteLibelleFlux'];
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
