import 'dart:convert';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/pays_model.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class PaysService {
  static Future<List<PaysModel>> getAllPays() async {
    var body = '''
      query {
      allCountries {
          _id
          name
          code
          tauxTVA
          initiauxPays
          phoneNumber
      }
    }
            ''';
    var response = await http.post(
      Uri.parse(serverUrl),
      body: json.encode({
        'query': body,
      }),
      headers: getHeaders(),
    ).catchError((onError) {
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.failgettingDataMessage;
      },
    );
    List<PaysModel> payss = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['allCountries'];
      if (data != null) {
        for (var pays in data) {
          payss.add(PaysModel.fromJson(pays));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return payss;
  }

  static Future<RequestResponse> createPays({
    required String nom,
    required List<int> initiauxPays,
    required double taux,
    required int nbreNumTel,

    required int code,
  }) async {
    var body = '''
    mutation {
    createCountry(name: "$nom", code: $code, phoneNumber: $nbreNumTel, tauxTVA: $taux, initiauxPays: $initiauxPays) 
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
          return RequestResponse.response(
            message: RequestMessage.timeoutMessage,
            status: PopupStatus.customError,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createCountry'];
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
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<RequestResponse> updatePays({
    required String paysId,
    String? nom,
    double? taux,
    int? nbreNumTel,
    required List<int> initiauxPays,

    int? code,
  }) async {
    var body = StringBuffer('''
    mutation UpdateCountry {
      updateCountry(
        key: "$paysId",
  ''');

    if (nom != null) {
      body.write('name: "$nom",');
    }
    if (taux != null) {
      body.write('tauxTVA: $taux,');
    }
    if (nbreNumTel != null) {
      body.write('phoneNumber: $nbreNumTel,');
    }
    if (code != null) {
      body.write('code: $code,');
    }
    if (initiauxPays.isNotEmpty) {
      body.write('initiauxPays: ${initiauxPays.toList()},');
    }

    body.write(') }');

    try {
      var response = await http.post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body.toString()}),
        headers: getHeaders(),
      ).timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          return RequestResponse.response(

            status: PopupStatus.serverError,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateCountry'];

        if (data != null) {
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
}
