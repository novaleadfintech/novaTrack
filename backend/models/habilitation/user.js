import { aql } from "arangojs";
import crypto from "crypto";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import Personnel from "./personnel.js";
import Role from "./role.js";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import { EtatPersonnel } from "./personnel.js";
import {
  sendRoleAssignmentEmail,
  sendresetLoginEmail,
} from "../../utils/send_email.js";


const personnelModel = new Personnel();
const roleModel = new Role();
const userCollection = db.collection("utilisateurs");
const userRoleCollection = db.collection("userRoles");

dotenv.config();
const roleAuthorization = {
  accepted: "accepted",
  wait: "wait",
  refused: "refused",
};
const generateToken = ({ user, password }) => {
  const cleanedRoles = user.roles.map(
    ({ _key, roleKey, permissionKey, roleAuthorization, role }) => ({
      _key,
      roleKey,
      permissionKey,
      roleAuthorization,
      role: { _key: role._key, libelle: role.libelle },
    }),
  );
  return jwt.sign(
    {
      user: {
        _key: user._key,
        login: user.login,
        password: password,
        personnel: {
          _key: user.personnel._key,
          nom: user.personnel.nom,
          prenom: user.personnel.prenom,
        },
        roles: cleanedRoles,
      },
    },
    process.env.TOKEN_SECRET_KEY,
  );
};

//generer un mot de passe
const generatePassword = (length = 6) => {
  return crypto.randomBytes(length).toString("hex").slice(0, length);
};

//la fonction de hachage du mot de passe
const hashPassword = async ({ password }) => {
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);
  return hashedPassword;
};

// Fonction pour générer un login unique
/*const generateLogin = async ({ personnel }) => {
  let { prenom, nom } = personnel;
  let increment = 1;
  while (prenom.length < 4) {
    prenom = `${prenom}${increment}`;
  }
  const login = `${nom.charAt(0).toLowerCase()}${prenom
    .slice(0, 4)
    .toLowerCase()}`;

  // Vérifier l'unicité du login
  let count = 1;
  let uniqueLogin = login;

  let existingLogins = await db.query(aql`
    FOR user IN ${userCollection}
    FILTER user.login == ${uniqueLogin}
    RETURN user
  `);

  while (existingLogins.hasNext) {
    uniqueLogin = `${login}${count}`;
    existingLogins = await db.query(aql`
      FOR user IN ${userCollection}
      FILTER user.login == ${uniqueLogin}
      RETURN user
    `);
    count += 1;
  }
  return uniqueLogin;
};*/

class User {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await userCollection.exists())) {
      userCollection.create();
    }
    if (!(await userRoleCollection.exists())) {
      await userRoleCollection.create();
    }
  }

  //recuperer tous les users
  getAllUsers = async () => {
    try {
      const query = await db.query(
        aql`FOR user IN ${userCollection} SORT user._key RETURN user`,
      );

      if (query.hasNext) {
        const users = await query.all();
        return Promise.all(
          users.map(async (user) => {
            return {
              ...user,
              roles: this.getRoleByUser({ userKey: user._key }),
              personnel: await personnelModel.getPersonnel({
                key: user.personnelKey,
              }),
            };
          }),
        );
      } else {
        return [];
      }
    } catch {
      throw new Error("Erreur lors de la récupération des utilisateurs");
    }
  };

  getRoleByUser = async ({ userKey }) => {
    try {
      const query = await db.query(aql`
          FOR userrole IN ${userRoleCollection}
          FILTER userrole.userKey == ${userKey}
          SORT userrole.timeStamp ASC
          RETURN userrole
        `);
      if (query.hasNext) {
        const userRoles = await query.all();
        return Promise.all(
          userRoles.map(async (userRole) => {
            const role = await roleModel.getRole({ key: userRole.roleKey });
            return {
              ...userRole,
              role: role,
              createBy: userRole.createBy
                ? await this.getUser({ key: userRole.createBy })
                : null,
              authorizer: userRole.authorizer
                ? await this.getUser({ key: userRole.authorizer })
                : null,
            };
          }),
        );
      }
      return [];
    } catch (err) {
      console.error(err);
      throw new Error(
        "Erreur lors de la récupération des rôles de l'utilisateur",
      );
    }
  };
  //recuperation d'un user à partir de sa clé
  getUser = async ({ key }) => {
    try {
      const user = await userCollection.document(key);
      const personnel = await personnelModel.getPersonnel({
        key: user.personnelKey,
      });
      const roles = await this.getRoleByUser({ userKey: user._key });
      return {
        ...user,
        personnel: personnel,
        roles: roles,
      };
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de la récupération de l'utilisateur");
    }
  };

  attribuerRolePersonnel = async ({ personnelKey, roleKey, userKey }) => {
    let personnel, role, newUser;

    // Vérifications préalables
    await personnelModel.isExistPersonnel({ key: personnelKey });
    await roleModel.isExistRole({ key: roleKey });

    const userDoublonpersonnel = await db.query(
      aql`FOR user IN ${userCollection} FILTER user.personnelKey == ${personnelKey} RETURN user`,
    );

    if (userDoublonpersonnel.hasNext) {
      const user = await userDoublonpersonnel.next();
      const userDoublon = await db.query(
        aql`FOR userRole IN ${userRoleCollection} FILTER userRole.userKey == ${user._key} AND userRole.roleKey == ${roleKey} RETURN userRole`,
      );

      if (userDoublon.hasNext) {
        const userRoleExistant = await userDoublon.all();
        if (userRoleExistant.length > 0) {
          for (const userRole of userRoleExistant) {
            if (userRole.roleAuthorization == roleAuthorization.wait) {
              throw new Error(
                "Ce personnel a déjà un rôle en attente de validation.",
              );
            }
          }
        }

        // throw new Error("Ce personnel a déjà ce rôle");
      }

      try {
        // const user = await userDoublonpersonnel.next();
        userRoleCollection.save({
          userKey: user._key,
          roleKey: roleKey,
          roleAuthorization: roleAuthorization.wait,
          createBy: userKey,
          timeStamp: Date.now(),
        });
        return "OK";
      } catch (e) {
        console.error(e);
        throw new Error("Erreur lors de l'attribution du rôle au personnel");
      }
    }

    personnel = await personnelModel.getPersonnel({ key: personnelKey });
    role = await roleModel.getRole({ key: roleKey });

    const password = generatePassword();
    const hashedPassword = await hashPassword({ password: password });

    const user = {
      login: personnel.email,
      password: hashedPassword,
      personnelKey: personnelKey,
      isTheFirstConnection: true,
      dateEnregistrement: Date.now(),
      canLogin: true,
    };

    const trx = await db.beginTransaction({
      write: [userCollection, userRoleCollection],
    });

    try {
      const userQuery = await trx.step(() =>
        userCollection.save(user, { returnNew: true }),
      );
      newUser = userQuery.new;
      await trx.step(() =>
        userRoleCollection.save({
          userKey: newUser._key,
          roleKey: roleKey,
          createBy: userKey,
          roleAuthorization: roleAuthorization.wait,
          timeStamp: Date.now(),
        }),
      );

      let info = await sendRoleAssignmentEmail({
        password: password,
        personnel: personnel,
        role: role,
        user: newUser,
      }).catch((error) => {
        throw new Error(error.message);
      });

      await trx.commit();

      return "OK";
    } catch (error) {
      console.error(error);
      await trx.abort();
      throw new Error(
        "Une erreur s'est produite lors de l'attribution du rôle.",
      );
    }
  };

  handleRoleEditing = async ({ userRoleKey, decision, userKey }) => {
    isValidValue({ value: { decision, userRoleKey, userKey } });
    try {
      await userRoleCollection.update(userRoleKey, {
        roleAuthorization: decision,
        authorizer: userKey,
        authorizeTime: Date.now(),
      });
      return "OK";
    } catch (error) {
      console.error(error);
      throw new Error(`Une erreur s'est produite lors du traitement`);
    }
  };

  attribuerRoleUser = async ({ userKey, roleKey }) => {
    await this.isExistUser({ key: userKey });

    await roleModel.isExistRole({ key: roleKey });

    const doublon = await db.query(
      aql`FOR userRole IN ${userRoleCollection} FILTER userRole.userKey == ${userKey} AND userRole.roleKey == ${roleKey} RETURN userRole`,
    );

    if (doublon.hasNext) {
      const role = await roleModel.getRole(roleKey);
      throw new Error(`Cet utilisateur joue dejà le rôle de ${role.libelle}`);
    }
    try {
      await userRoleCollection.save({ userKey: userKey, roleKey: roleKey });
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de l'attribution du role.",
      );
    }
  };

  retirerRoleUser = async ({ userKey, roleKey }) => {
    try {
      const query = await db.query(
        aql`FOR userRole IN ${userRoleCollection} FILTER userRole.userkey == ${userKey} AND  userRole.roleKey == ${roleKey} RETURN userRole REMOVE userRole IN ${userRoleCollection}`,
      );
      if (query.hasNext) {
        return "OK";
      }
    } catch (err) {
      console.error(err);

      throw new Error("Une erreur s'est produite lors de l'opération'.");
    }
  };

  /*  deleteUser = async ({ userKey, }) => {
    try {
      const query = await db.query(
        aql`FOR userRole IN ${userRoleCollection} FILTER userRole.userKey == ${userKey} AND  userRole.roleKey == ${roleKey} RETURN userRole REMOVE userRole IN ${userRoleCollection}`
      );
      if (query.hasNext) {
        return "OK";
      }
    } catch (err) {
    console.error(err);

      throw new Error("Une erreur s'est produite lors de l'opération'.");
    }
  }; */

  updateLoginData = async ({ key, login, password, oldPassword }) => {
    isValidValue({ value: { password, oldPassword } });
    let updateFied = {};
    if (login != null) {
      updateFied.login = login;
    }
    if (oldPassword != undefined) {
      const currentUser = await this.getUser({ key: key });
      const isPasswordCorrect = await bcrypt.compare(
        oldPassword,
        currentUser.password,
      );
      if (!isPasswordCorrect) {
        throw new Error(
          "Verifiez votre ancienne mot de passe et réssayer la modification.",
        );
      }
    } else {
    }
    if (password != null) {
      const strongPasswordRegex =
        /^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*\d).{8,}$/;
      if (!strongPasswordRegex.test(password)) {
        throw new Error(
          "Le mot de passe doit contenir au moins 8 caractères, une majuscule, un chiffre et un caractère spécial.",
        );
      }
      const hashed = await hashPassword({ password: password });
      updateFied.password = hashed;
    }

    isValidValue({ value: updateFied });

    try {
      await userCollection.update(key, {
        ...updateFied,
        isTheFirstConnection: false,
      });
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de la mise à jour des paramètre de connexion.",
      );
    }
  };

  seConnecter = async ({ login, password }) => {
    isValidValue({ value: [login, password] });
    var existingUser = null;
    try {
      existingUser = await db.query(
        aql`FOR user IN ${userCollection} FILTER user.login==${login} RETURN user`,
      );
    } catch {
      throw new Error(
        "Cet utilisateur n'existe pas ou les données de connexion sont incorrectes.",
      );
    }

    if (existingUser.hasNext) {
      const user = await existingUser.next();
      const currentUser = await this.getUser({ key: user._key });
      const isPasswordCorrect = await bcrypt.compare(
        password,
        currentUser.password,
      );
      if (!isPasswordCorrect) {
        throw new Error("Mot de passe incorrecte.");
      }
      if (
        currentUser.personnel.etat == EtatPersonnel.archived ||
        !currentUser.canLogin
      ) {
        throw new Error(
          "Vous n'êtes plus autoriseés à avoir accès à ce système.",
        );
      }
      const token = generateToken({ user: currentUser, password: password });
      await userCollection.update(currentUser._key, {
        _token: token,
      });
      return await this.getUser({ key: currentUser._key });
    } else {
      throw new Error("Les données de connexion sont incorrectes.");
    }
  };

  seDeconnecter = async ({ key }) => {
    try {
      const logout = await db.query(aql`
        FOR user IN ${userCollection}
        FILTER user._key == ${key}
        UPDATE user WITH UNSET(user, '_token') IN ${userCollection}
        RETURN NEW
      `);
      if (logout.hasNext) {
        return "OK";
      } else {
        throw new Error("Déconnexion impossible!");
      }
    } catch {
      throw new Error("Déconnexion impossible!");
    }
  };

  isExistUser = async ({ key }) => {
    const exist = await userCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cet utilisateur n'existe pas!");
    }
  };

  access = async ({ key, canLogin }) => {
    try {
      await userCollection.update(key, { canLogin: canLogin });
      return "OK";
    } catch {
      throw new Error("Erreur lors de l'opération");
    }
  };

  resetLoginParameter = async ({ key }) => {
    const user = await this.getUser({ key: key });
    const password = generatePassword();
    const hashedPassword = await hashPassword({ password: password });
    const trx = await db.beginTransaction({
      write: [userCollection],
    });
    try {
      await trx.step(async () =>
        userCollection.update(key, {
          login: user.personnel.email,
          password: hashedPassword,
        }),
      );
      let info = await sendresetLoginEmail({
        password: password,
        personnel: user.personnel,
      }).catch((error) => {
        throw new Error("Echec d'envoi d'email");
      });

      await trx.commit();
      return "OK";
    } catch (error) {
      console.error(error);
      await trx.abort();
      throw new Error(
        `Une erreur s'est produite lors de la réinitialisation du paramètre de connexion de ${user.personnel.nom} ${user.personnel.prenom}`,
      );
    }
  };
}
export default User;
