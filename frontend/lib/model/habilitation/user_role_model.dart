import 'role_enum.dart';
import 'user_model.dart';
import 'role_model.dart';

class UserRoleModel {
  final String id;
  final RoleAuthorization? roleAuthorization;
  final RoleModel role;
  final UserModel? authorizer;
  final DateTime? authorizeTime;
  final UserModel? createBy;
  final DateTime? timeStamp;

  UserRoleModel({
    required this.id,
    required this.role,
    required this.timeStamp,
    this.roleAuthorization,
    this.authorizer,
    this.authorizeTime,
    this.createBy,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
     return UserRoleModel(
      id: json['_id'],
      role: RoleModel.fromJson(json['role']),
      timeStamp: json['timeStamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['timeStamp']))
          : null,
      roleAuthorization: json['roleAuthorization'] != null
          ? RoleAuthorization.roleAuthorizationFromString(
              json['roleAuthorization'])
          : null,
      authorizer: json['authorizer'] != null
          ? UserModel.fromJson(json['authorizer'])
          : null,
      authorizeTime: json['authorizeTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['authorizeTime']))
          : null,
      createBy: json['createBy'] != null
          ? UserModel.fromJson(json['createBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'role': role.toJson(),
      'timeStamp': timeStamp,
      if (roleAuthorization != null)
        'roleAuthorization':
            RoleAuthorization.roleAuthorizationToString(roleAuthorization!),
      if (authorizer != null) 'Authorizer': authorizer!.toJson(),
      if (authorizeTime != null) 'authorizeTime': authorizeTime,
      if (createBy != null) 'createBy': createBy!.toJson(),
    };
  }
}
