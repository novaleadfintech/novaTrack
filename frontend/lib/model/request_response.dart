import '../app/integration/popop_status.dart';

class RequestResponse {
  final String? message;
  final PopupStatus status;

  RequestResponse({
    this.message,
    required this.status,
  });

  static response({String? message, required PopupStatus status}) =>
      RequestResponse(
        status: status,
        message: message!,
      );
}
