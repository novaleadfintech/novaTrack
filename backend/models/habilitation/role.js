import { aql, CollectionType } from "arangojs";
import db from "../../db/database_connection.js";
import Permission from "./permission.js";
import { isValidValue } from "../../utils/util.js";

const roleCollection = db.collection("roles");
const rolePermissionEdges = db.collection("rolePermissions");
const permissionModel = new Permission();

class Role {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await roleCollection.exists())) {
      roleCollection.create();
    }
    if (!(await rolePermissionEdges.exists())) {
      roleCollection.create({ type: CollectionType.EDGE_COLLECTION });
    }
  }
  getAllRoles = async () => {
    const query = await db.query(
      aql`FOR role IN ${roleCollection} RETURN role`
    );
    if (query.hasNext) {
      const roles = await query.all();
      return await Promise.all(
        roles.map(async (role) => {
           return {
            ...role,
            permissions: await permissionModel.getPermissionByRole({
              roleId: role._id,
            }),
          };
        })
      );
    } else {
      return [];
    }
  };

  getRole = async ({ key }) => {
    try {
      const role = await roleCollection.document(key);
      return {
        ...role,
        permissions: await permissionModel.getAllPermissionsByRoleForUser({
          roleId: key,
        }),
      };
    } catch (err) {
      console.error(err);

      throw new Error("Ce rôle est introuvable");
    }
  };

  //creer un nouveau role
  createRole = async ({ libelle }) => {
    isValidValue({ value: libelle });
    const newRole = {
      libelle: libelle,
    };
    try {
      await roleCollection.save(newRole);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de l'enregistrement");
    }
  };

  attribuerPermissionRole = async ({ key, permissionId }) => {
    await this.isExistRole({ key: key });
    await permissionModel.isExistPermission({ key: permissionId });
    const query = await db.query(aql`
        FOR rolePermission IN ${rolePermissionEdges}
        FILTER rolePermission._from == ${key} AND rolePermission._to == ${permissionId}
        RETURN rolePermission
      `);
    if (query.hasNext) {
      return "OK";
    } else {
      try {
        const rolePermission = {
          _from: key,
          _to: permissionId,
        };
        await rolePermissionEdges.save(rolePermission);
        return "OK";
      } catch (err) {
        console.error(err);

        throw new Error("Erreur lors de l'attribution de la permission");
      }
    }
  };

  retirerPermissionRole = async ({ key, permissionId }) => {
    try {
      const query = await db.query(aql`
      FOR rolePermission IN ${rolePermissionEdges}
      FILTER rolePermission._from == ${key} AND rolePermission._to == ${permissionId}
      RETURN rolePermission
    `);
      if (query.hasNext) {
        await rolePermissionEdges.remove(await query.next());
      }
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors du retrait");
    }
  };

  isExistRole = async ({ key }) => {
    const exist = await roleCollection.documentExists(key);
    if (!exist) {
      throw new Error("Ce rôle n'existe pas!");
    }
  };

  updateRole = async ({ key, libelle }) => {
    let updateField = {};
    if (libelle !== undefined) {
      updateField.libelle = libelle;
    }
    try {
      await roleCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la mise à jour");
    }
  };

  deleteRole = async ({ key }) => {
    try {
      const result = await rolePermissionEdges.edges(key);
      if (result.edges.length !== 0) {
        throw new Error("Suppression impossible");
      }
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la suppression");
    }
    try {
      await roleCollection.remove(key);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la suppression");
    }
  };
}

export default Role;
