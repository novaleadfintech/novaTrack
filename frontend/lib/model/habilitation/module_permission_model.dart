// permission.dart

import 'module_model.dart';
import 'permission_model.dart';

class ModulePermissionModel {
  ModuleModel module;
  List<PermissionModel?> permissions;

  ModulePermissionModel({
    required this.module,
    required this.permissions,
  });

  factory ModulePermissionModel.fromJson(Map<String, dynamic> json) {
    List<PermissionModel>? permissionsList =
        (json['permissions'] as List<dynamic>?)!
            .map((permission) => PermissionModel.fromJson(permission))
            .toList();
    return ModulePermissionModel(
      module: ModuleModel.fromJson(json['module']),
      permissions: permissionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'permissions':
          permissions.map((permission) => permission?.toJson()).toList(),
    };
  }
}
