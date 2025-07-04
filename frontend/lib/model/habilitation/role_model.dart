import 'permission_model.dart';
import 'role_enum.dart';

class RoleModel {
  final String? id;
  final String libelle;
  final RoleAuthorization? roleAuthorization;
  final List<PermissionModel>? permissions;

  RoleModel({
    this.id,
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
      id: json['_id'],
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
      '_id': id,
      'libelle': libelle,
      'roleAuthorization': roleAuthorization != null
          ? RoleAuthorization.roleAuthorizationToString(roleAuthorization!)
          : null,
      'permissions':
          permissions?.map((permission) => permission.toJson()).toList(),
    };
  }
}
