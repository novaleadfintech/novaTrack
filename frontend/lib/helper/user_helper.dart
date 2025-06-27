import '../model/habilitation/role_model.dart';

bool hasPermission(
    {required List<RoleModel> roles, required String permission}) {
  return roles.any((role) {
    return role.permissions!.any((perm) {
      return perm.alias == permission;
    });
  });
}

bool hasModule({required List<RoleModel> roles, required String module}) {
  return roles.any((role) {
    return role.permissions!.any((perm) {
      return perm.module!.alias == module;
    });
  });
}
