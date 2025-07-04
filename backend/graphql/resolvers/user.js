import User from "../../models/habilitation/user.js";

const userModel = new User();

const userResolvers = {
  //recuperer tous les users
  users: async () => {
    return await userModel.getAllUsers();
  },

  //recuperation d'un user à partir de sa clé
  user: async ({ key }) => await userModel.getUser({ key: key }),

  //attribuer un role à un personnel
  attribuerRolePersonnel: async ({ personnelId, roleId, createBy }) =>
    await userModel.attribuerRolePersonnel({
      personnelId: personnelId,
      roleId: roleId,
      userId: createBy,
    }),

  updateLoginData: async ({ key, login, password, oldPassword }) =>
    await userModel.updateLoginData({
      key: key,
      login: login,
      password: password,
      oldPassword: oldPassword,
    }),

  resetLoginParameter: async ({ key }) =>
    await userModel.resetLoginParameter({ key: key }),

  access: async ({ key, canLogin }) =>
    await userModel.access({ key: key, canLogin: canLogin }),

  attribuerRoleUser: async ({ key, roleId }) =>
    await userModel.attribuerRoleUser({ key: key, roleId: roleId }),

  retirerRoleUser: async ({ key, roleId }) =>
    await userModel.retirerRoleUser({ key: key, roleId: roleId }),

  seConnecter: async ({ login, password }) => {
    return await userModel.seConnecter({ login: login, password: password });
  },

  handleRoleEditing: async ({ userRoleId, roleAuthorization, authorizer }) =>
    await userModel.handleRoleEditing({
      userRoleId: userRoleId,
      decision: roleAuthorization,
      userId: authorizer,
    }),

  seDeconnecter: async ({ key }) => await userModel.seDeconnecter({ key: key }),
};

export default userResolvers;
