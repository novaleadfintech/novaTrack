
import '../personnel/personnel_model.dart';
import 'user_role_model.dart';

class UserModel {
  final String? id;
  final String? login;
  final String? password;
  final PersonnelModel? personnel;
  final List<UserRoleModel>? roles;
  final bool? canLogin;
  final bool? isTheFirstConnection; // Added field for first connection
  final String? token;
  final DateTime? dateEnregistrement;

  UserModel({
    this.id,
    this.login,
    this.password,
    this.personnel,
    this.isTheFirstConnection,
    this.roles,
    this.canLogin,
    this.token,
    this.dateEnregistrement,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      login: json['login'],
      password: json['password'],
      personnel: json['personnel'] != null
          ? PersonnelModel.fromJson(json['personnel'])
          : null,
      roles: json['roles'] != null
          ? (json['roles'] as List)
              .map((role) => UserRoleModel.fromJson(role))
              .toList()
          : null,
      canLogin: json['canLogin'] ?? false,
      isTheFirstConnection: json['isTheFirstConnection'] ?? false,
      token: json['_token'],
      dateEnregistrement: json['dateEnregistrement'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateEnregistrement'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'login': login,
      'password': password,
      'personnel': personnel?.toJson(),
      'roles': roles?.map((role) => role.toJson()).toList(),
      'canLogin': canLogin,
      '_token': token,
      'dateEnregistrement': dateEnregistrement?.millisecondsSinceEpoch,
    };
  }

  String toStringify() {
    return personnel!.toStringify();
  }

  bool equalTo({required UserModel? user}) {
    if (user == null) return false;
    return user.id == id;
  }
}
