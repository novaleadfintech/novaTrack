import 'package:http/http.dart' as http;

class TokenClient extends http.BaseClient {
  final String token;
  final http.Client _inner;

  TokenClient(this.token, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $token';
    return _inner.send(request);
  }
}