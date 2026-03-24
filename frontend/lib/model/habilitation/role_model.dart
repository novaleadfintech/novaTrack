import 'permission_model.dart';
import 'role_enum.dart';

class RoleModel {
  final String? key;
  final String libelle;
  final RoleAuthorization? roleAuthorization;
  final List<PermissionModel>? permissions;

  RoleModel({
    this.key,
    required this.libelle,
    required this.roleAuthorization,
    this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    List<PermissionModel>? permissionsList =
        (json['permissions'] as List<dynamic>?)
            ?.map((permission) => PermissionModel.fromJson(permission))
            .toList();
    return RoleModel(
      key: json['_key'],
      roleAuthorization: json['roleAuthorization'] != null
          ? RoleAuthorization.roleAuthorizationFromString(
              json['roleAuthorization'])
          : null,
      libelle: json['libelle'],
      permissions: permissionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_key': key,
      'libelle': libelle,
      'roleAuthorization': roleAuthorization != null
          ? RoleAuthorization.roleAuthorizationToString(roleAuthorization!)
          : null,
      'permissions':
          permissions?.map((permission) => permission.toJson()).toList(),
    };
  }
}
