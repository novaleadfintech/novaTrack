import Role from "../../models/habilitation/role.js";

const roleModel = new Role();

const roleResolvers = {
  //recuperer tous les roles
  roles: async () => await roleModel.getAllRoles(),

  //recuperer un role
  role: async ({ key }) => await roleModel.getRole({ key: key }),

  //creer un nouveau role
  createRole: async ({ libelle }) =>
    await roleModel.createRole({ libelle: libelle }),

  //retirer une permission à un profil ou role
  retirerPermissionRole: async ({ rolekey, permissionKey }) =>
    await roleModel.retirerPermissionRole({
      roleKey: rolekey,
      permissionKey: permissionKey,
    }),

  //attribuer une permission à un profil ou role
  attribuerPermissionRole: async ({ rolekey, permissionKey }) =>
    await roleModel.attribuerPermissionRole({
      roleKey: rolekey,
      permissionKey: permissionKey,
    }),

  roleByUser: async ({ userKey }) =>
    await roleModel.getRoleByUser({ userKey: userKey }),

  updateRole: async ({ key, libelle }) =>
    await roleModel.updateRole({ key: key, libelle: libelle }),

  deleteRole: async ({ key }) => await roleModel.deleteRole({ key: key }),
};

export default roleResolvers;
