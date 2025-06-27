import 'dart:convert';
import 'package:frontend/model/client/client_model.dart';
import 'package:frontend/model/facturation/facture_global_value_model.dart';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';

import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class ClientFactureGlobalValuesService {
  static Future<List<ClientFactureGlobaLValueModel>>
      getClientFactureGlobalValues() async {
    var body = '''
      query ClientFactureGlobalValues {
    clientFactureGlobalValues {
      nbreJrMaxPenalty
       client {
            _id
            email
            telephone
            adresse
            nature
            etat
            dateEnregistrement
            fullCount
            pays {
                     _id
          name
          code
          tauxTVA
          phoneNumber
                  }
            ... on ClientMoral {
                _id
                raisonSociale
                logo
                email
                nature
                telephone
                adresse
                etat
                dateEnregistrement
                fullCount
                pays {
                     _id
          name
          code
          tauxTVA
          phoneNumber
                  }
            }
            ... on ClientPhysique {
                _id
                nom
                prenom
                sexe
                nature
                email
                telephone
                adresse
                etat
                dateEnregistrement
                fullCount
                pays {
                     _id
          name
          code
          tauxTVA
          phoneNumber
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
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.failgettingDataMessage;
      },
    );
    List<ClientFactureGlobaLValueModel> configValues = [];

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['clientFactureGlobalValues'];
       if (data != null) {
        for (var configValue in data) {
          configValues.add(ClientFactureGlobaLValueModel.fromJson(configValue));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return configValues;
  }

  static Future<RequestResponse> configClientFactureGlobaLValue({
    required int nbreJrMaxPenalty,
    required ClientModel client,
  }) async {
    var body = '''
      mutation ConfigClientFactureGlobaLValue {
       configClientFactureGlobaLValue(clientId: "${client.id}", nbreJrMaxPenalty: $nbreJrMaxPenalty)
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
        var data = jsonData['data']['configClientFactureGlobaLValue'];
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
      rethrow;
    }
  }
}
