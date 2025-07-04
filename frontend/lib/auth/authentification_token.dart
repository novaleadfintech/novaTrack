import 'dart:convert';
import 'package:frontend/model/habilitation/role_model.dart';
import '../model/habilitation/user_model.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  String? _token;

  AuthService._internal();

  Future<void> setToken(String token) async {
    _token = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  String getToken() {
    return _token!;
  }

  Future<void> clearToken() async {
    _token = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
  }

  Future<UserModel?> decodeToken() async {
    getToken();
    if (_token != null) {
      Map<String, dynamic> token = Jwt.parseJwt(_token!);

      return UserModel.fromJson(token["user"]);
    }
    return null;
  }

  Future<void> setRoles(RoleModel role) async {
    final prefs = await SharedPreferences.getInstance();
    final rolesJson = jsonEncode(role.toJson());
    await prefs.setString("role", rolesJson);
  }

  Future<RoleModel> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleJson = prefs.getString("role");
     
    if (roleJson == null) throw "Aucun rôle trouvé";

    final Map<String, dynamic> decoded = jsonDecode(roleJson);
    return RoleModel.fromJson(decoded);
  }
}
