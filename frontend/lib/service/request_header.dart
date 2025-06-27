import '../auth/authentification_token.dart';

Map<String, String> getHeaders() {
  try {
     final token = AuthService().getToken();
     return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  } catch (e) {
    return {
      "Content-Type": "application/json",
      "Authorization": "",
    };
  }
}
