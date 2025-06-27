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
  retirerPermissionRole: async ({ rolekey, permissionId }) =>
    await roleModel.retirerPermissionRole({
      key: rolekey,
      permissionId: permissionId,
    }),

  //attribuer une permission à un profil ou role
  attribuerPermissionRole: async ({ rolekey, permissionId }) =>
    await roleModel.attribuerPermissionRole({
      key: rolekey,
      permissionId: permissionId,
    }),

  roleByUser: async ({ userId }) =>
    await roleModel.getRoleByUser({ userId: userId }),

  updateRole: async ({ key, libelle }) =>
    await roleModel.updateRole({ key: key, libelle: libelle }),

  deleteRole: async ({ key }) => await roleModel.deleteRole({ key: key }),
};

export default roleResolvers;
