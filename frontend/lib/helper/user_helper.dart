import '../model/habilitation/role_model.dart';

bool hasPermission(
    {required RoleModel role, required String permission}) {
  
    return role.permissions!.any((perm) {
      return perm.alias == permission;
    });
  
}

bool hasModule({required RoleModel role, required String module}) {
  return role.permissions!.any((perm) {
      return perm.module!.alias == module;
    });
  
}
