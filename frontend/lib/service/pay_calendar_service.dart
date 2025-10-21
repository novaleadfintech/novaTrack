import 'dart:convert';
 
import 'package:frontend/model/bulletin_paie/calendar_model.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
 import '../model/request_response.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class PayCalendarService {
  static Future<List<PayCalendarModel>> getPayCalendars() async {
    var body = '''
      query PayCalendars {
          payCalendars {
              _id
              libelle
              dateDebut
              dateFin
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
    List<PayCalendarModel> payCalendars = [];

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['payCalendars'];
      if (data != null) {
        for (var payCalendar in data) {
          payCalendars.add(PayCalendarModel.fromJson(payCalendar));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return payCalendars;
  }

  static Future<RequestResponse> createPayCalendar({
    required String libelle,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    var body = '''
    mutation CreatePayCalendar {
    createPayCalendar(libelle: "$libelle", dateDebut: ${dateDebut.millisecondsSinceEpoch}, dateFin: ${dateFin.millisecondsSinceEpoch})
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
        var data = jsonData['data']['createPayCalendar'];
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

  static Future<RequestResponse> updatePayCalendar({
    required String key,
    required String libelle,
    required DateTime? dateDebut,
    required DateTime? dateFin,
  }) async {
    var body = '''
     mutation UpdatePayCalendar {
    updatePayCalendar(key: "$key", libelle: "$libelle",
      dateDebut: ${dateDebut?.millisecondsSinceEpoch},
      dateFin: ${dateFin?.millisecondsSinceEpoch},
    )
}

    ''';
//TODO : c'est à completer
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
        var data = jsonData['data']['updatePayCalendar'];
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

  static Future<RequestResponse> deletePayCalendar({
    required String key,
  }) async {
    var body = '''
     mutation DeletePayCalendar {
    deletePayCalendar(key: "$key")
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
        var data = jsonData['data']['deletePayCalendar'];
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
