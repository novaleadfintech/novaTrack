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
    ({ _id, _from, _to, roleAuthorization, role }) => ({
      _id,
      _from,
      _to,
      roleAuthorization,
      role: { _id: role._id, libelle: role.libelle },
    })
  );
  console.log("cleanedRoles", cleanedRoles);
  return jwt.sign(
    {
      user: {
        _id: user._id,
        login: user.login,
        password: password,
        personnel: {
          _id: user.personnel._id,
          nom: user.personnel.nom,
          prenom: user.personnel.prenom,
        },
        roles: cleanedRoles,
      },
    },
    process.env.TOKEN_SECRET_KEY
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
  constructor() {}

  //recuperer tous les users
  getAllUsers = async () => {
    try {
      const query = await db.query(
        aql`FOR user IN ${userCollection} SORT user._id RETURN user`
      );

      if (query.hasNext) {
        const users = await query.all();
        return Promise.all(
          users.map(async (user) => {
            return {
              ...user,
              roles: this.getRoleByUser({ userId: user._id }),
              personnel: await personnelModel.getPersonnel({
                key: user.personnelId,
              }),
            };
          })
        );
      } else {
        return [];
      }
    } catch {
      throw new Error("Erreur lors de la récupération des utilisateurs");
    }
  };

  getRoleByUser = async ({ userId }) => {
    try {
      const query = await db.query(aql`
          FOR userrole IN ${userRoleCollection}
          FILTER userrole._from == ${userId}
          SORT userrole.timeStamp ASC
          RETURN userrole
        `);

      if (query.hasNext) {
        const userRoles = await query.all();

        return Promise.all(
          userRoles.map(async (userRole) => {
            const role = await roleModel.getRole({ key: userRole._to });
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
          })
        );
      }
      return [];
    } catch (err) {
      console.error(err);
      throw new Error(
        "Erreur lors de la récupération des rôles de l'utilisateur"
      );
    }
  };
  //recuperation d'un user à partir de sa clé
  getUser = async ({ key }) => {
    try {
      const user = await userCollection.document(key);
      const personnel = await personnelModel.getPersonnel({
        key: user.personnelId,
      });

      const roles = await this.getRoleByUser({ userId: user._id });

      return {
        ...user,
        personnel: personnel,
        roles: roles,
      };
    } catch (e) {
      throw new Error(
        "Erreur lors de la récupération de l'utilisateur " + e.message
      );
    }
  };

  attribuerRolePersonnel = async ({ personnelId, roleId, userId }) => {
    let personnel, role, newUser;

    // Vérifications préalables
    await personnelModel.isExistPersonnel({ key: personnelId });
    await roleModel.isExistRole({ key: roleId });

    const userDoublonpersonnel = await db.query(
      aql`FOR user IN ${userCollection} FILTER user.personnelId == ${personnelId} RETURN user`
    );

    if (userDoublonpersonnel.hasNext) {
      const user = await userDoublonpersonnel.next();
      const userDoublon = await db.query(
        aql`FOR userRole IN ${userRoleCollection} FILTER userRole._from == ${user._id} AND userRole._to == ${roleId} RETURN userRole`
      );

      if (userDoublon.hasNext) {
        const userRoleExistant = await userDoublon.all();
        if (userRoleExistant.length > 0) {
          for (const userRole of userRoleExistant) {
            if (userRole.roleAuthorization == roleAuthorization.wait) {
              throw new Error(
                "Ce personnel a déjà un rôle en attente de validation."
              );
            }
          }
        }

        // throw new Error("Ce personnel a déjà ce rôle");
      }

      try {
        // const user = await userDoublonpersonnel.next();
        userRoleCollection.save({
          _from: user._id,
          _to: roleId,
          roleAuthorization: roleAuthorization.wait,
          createBy: userId,
          timeStamp: Date.now(),
        });
        return "OK";
      } catch (e) {
        throw new Error(e);
      }
    }

    personnel = await personnelModel.getPersonnel({ key: personnelId });
    role = await roleModel.getRole({ key: roleId });

    const password = generatePassword();
    const hashedPassword = await hashPassword({ password: password });

    const user = {
      login: personnel.email,
      password: hashedPassword,
      personnelId: personnelId,
      isTheFirstConnection: true,
      dateEnregistrement: Date.now(),
      canLogin: true,
    };

    const trx = await db.beginTransaction({
      write: [userCollection, userRoleCollection],
    });

    try {
      const userQuery = await trx.step(() =>
        userCollection.save(user, { returnNew: true })
      );
      newUser = userQuery.new;
      await trx.step(() =>
        userRoleCollection.save({
          _from: newUser._id,
          _to: roleId,
          createBy: userId,
          roleAuthorization: roleAuthorization.wait,
          timeStamp: Date.now(),
        })
      );

      let info = await sendRoleAssignmentEmail({
        password: password,
        personnel: personnel,
        role: role,
        user: newUser,
      }).catch((error) => {
        throw new Error(error);
      });

      await trx.commit();

      return "OK";
    } catch (error) {
      await trx.abort();
      throw new Error(
        "Une erreur s'est produite lors de l'attribution du rôle." + error
      );
    }
  };

  handleRoleEditing = async ({ userRoleId, decision, userId }) => {
    isValidValue({ value: { decision, userRoleId, userId } });
    try {
      await userRoleCollection.update(userRoleId, {
        roleAuthorization: decision,
        authorizer: userId,
        authorizeTime: Date.now(),
      });
      console.log("pourtant j'ai presque tout fait");
      return "OK";
    } catch (error) {
      throw new Error(
        `Une erreur s'est produite lors du traitement > ${error.message}`
      );
    }
  };

  attribuerRoleUser = async ({ userId, roleId }) => {
    await this.isExistUser({ key: userId });

    await roleModel.isExistRole({ key: roleId });

    const doublon = await db.query(
      aql`FOR userRole IN ${userRoleCollection} FILTER userRole._from == ${userId} AND userRole._to == ${roleId} RETURN userRole`
    );

    if (doublon.hasNext) {
      const role = await roleModel.getRole(roleId);
      throw new Error(`Cet utilisateur joue dejà le rôle de ${role.libelle}`);
    }
    try {
      await userRoleCollection.save({ _from: userId, _to: roleId });
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de l'attribution du role."
      );
    }
  };

  retirerRoleUser = async ({ userId, roleId }) => {
    try {
      const query = await db.query(
        aql`FOR userRole IN ${userRoleCollection} FILTER userRole._from == ${userId} AND  userRole._to == ${roleId} RETURN userRole REMOVE userRole IN ${userRoleCollection}`
      );
      if (query.hasNext) {
        return "OK";
      }
    } catch (err) {
      throw new Error("Une erreur s'est produite lors de l'opération'.");
    }
  };

  /*  deleteUser = async ({ userId, }) => {
    try {
      const query = await db.query(
        aql`FOR userRole IN ${userRoleCollection} FILTER userRole._from == ${userId} AND  userRole._to == ${roleId} RETURN userRole REMOVE userRole IN ${userRoleCollection}`
      );
      if (query.hasNext) {
        return "OK";
      }
    } catch (err) {
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
        currentUser.password
      );
      if (!isPasswordCorrect) {
        throw new Error(
          "Verifiez votre ancienne mot de passe et réssayer la modification."
        );
      }
    } else {
    }
    if (password != null) {
      const strongPasswordRegex =
        /^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*\d).{8,}$/;
      if (!strongPasswordRegex.test(password)) {
        throw new Error(
          "Le mot de passe doit contenir au moins 8 caractères, une majuscule, un chiffre et un caractère spécial."
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
      throw new Error(
        "Une erreur s'est produite lors de la mise à jour des paramètre de connexion."
      );
    }
  };

  seConnecter = async ({ login, password }) => {
    console.log(login);

    isValidValue({ value: [login, password] });
    var existingUser = null;
    try {
      existingUser = await db.query(
        aql`FOR user IN ${userCollection} FILTER user.login==${login} RETURN user`
      );
    } catch {
      throw new Error(
        "Cet utilisateur n'existe pas ou les données de connexion sont incorrectes."
      );
    }

    if (existingUser.hasNext) {
      const user = await existingUser.next();
      const currentUser = await this.getUser({ key: user._id });

      const isPasswordCorrect = await bcrypt.compare(
        password,
        currentUser.password
      );
      if (!isPasswordCorrect) {
        throw new Error("Mot de passe incorrecte.");
      }
      if (
        currentUser.personnel.etat == EtatPersonnel.archived ||
        !currentUser.canLogin
      ) {
        throw new Error(
          "Vous n'êtes plus autoriseés à avoir accès à ce système."
        );
      }
      const token = generateToken({ user: currentUser, password: password });
      await userCollection.update(currentUser._key, {
        _token: token,
      });
      return await this.getUser({ key: currentUser._id });
    } else {
      throw new Error("Les données de connexion sont incorrectes.");
    }
  };

  seDeconnecter = async ({ key }) => {
    try {
      const logout = await db.query(aql`
        FOR user IN ${userCollection}
        FILTER user._id == ${key}
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
        })
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
      await trx.abort();

      throw new Error(
        `Une erreur s'est produite lors de la réinitialisation du paramètre de connexion de ${user.personnel.nom} ${user.personnel.prenom} : ${error.message}`
      );
    }
  };
}
export default User;
