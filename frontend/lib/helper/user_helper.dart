import 'package:flutter/material.dart';
import 'package:frontend/model/habilitation/user_role_model.dart';

import '../model/habilitation/role_enum.dart';
import '../model/habilitation/role_model.dart';

bool hasPermission({required RoleModel role, required String permission}) {
  return role.permissions!.any((perm) {
    return perm.alias == permission;
  });
}

bool hasModule({required RoleModel role, required String module}) {
  return role.permissions!.any((perm) {
    return perm.module!.alias == module;
  });
}

bool hasAcceptedRoleWithPermission(
    {required List<UserRoleModel> roles, required String permission}) {
  try {
    final acceptedRole = roles.lastWhere((userRole) {
      return userRole.roleAuthorization == RoleAuthorization.accepted;
    });
    return hasPermission(role: acceptedRole.role, permission: permission);
  } catch (e) {
    return false;
  }
}

bool verifyRoleAuthorization(
    {required List<UserRoleModel> roles,
    required RoleAuthorization roleAuthorization}) {
  try {
    roles.lastWhere((userRole) {
      return userRole.roleAuthorization == roleAuthorization;
    });
    return true;
  } catch (e) {
    return false;
  }
}

UserRoleModel? getRoleSwitchAutorization(
    {required List<UserRoleModel> roles,
    required RoleAuthorization roleAuthorization}) {
  try {
    return roles.lastWhere((userRole) {
      return userRole.roleAuthorization == roleAuthorization;
    });
  } catch (e) {
    debugPrint("$e");
  }
  return null;
}
