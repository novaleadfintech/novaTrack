import Permission from "../../models/habilitation/permission.js";

const permissionModel = new Permission();

const permissionResolvers = {
  //recuperer tous les permissions
  permissions: async () => await permissionModel.getAllPermissions(),
  //recuperer un permission avec son key
  permission: async ({ key }) =>
    await permissionModel.getPermission({ key: key }),
  //creer une nouvelle permission
  createPermission: async ({ libelle }) =>
    await permissionModel.createPermission({ libelle: libelle }),
  //recuperer un permission par role
  permissionByRole: async ({ roleKey }) => {
    return await permissionModel.getPermissionByRole({ roleKey: roleKey });
  },

  updatePermission: async ({ key, libelle }) =>
    await permissionModel.updatePermission({ key: key, libelle: libelle }),

  deletePermission: async ({ key }) =>
    await permissionModel.deletePermission({ key: key }),
};

export default permissionResolvers;
