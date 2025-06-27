import 'permission_model.dart';

class RoleModel {
  final String? id;
  final String libelle;
  final List<PermissionModel>? permissions;

  RoleModel({
    this.id,
    required this.libelle,
    this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    // Récupération des permissions à partir du JSON
    List<PermissionModel>? permissionsList =
        (json['permissions'] as List<dynamic>?)
            ?.map((permission) => PermissionModel.fromJson(permission))
            .toList();

    return RoleModel(
      id: json['_id'],
      libelle: json['libelle'],
      permissions: permissionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'libelle': libelle,
      'permissions':
          permissions?.map((permission) => permission.toJson()).toList(),
    };
  }
}
