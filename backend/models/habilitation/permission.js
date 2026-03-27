import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";


const permissionCollection = db.collection("permissions");
const moduleCollection = db.collection("modules");
const rolePermissionCollection  = db.collection("rolePermissions");

class Permission {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await permissionCollection.exists())) {
     await permissionCollection.create();
    }
    if (!(await moduleCollection.exists())) {
     await moduleCollection.create();
    }
    if (!(await rolePermissionCollection.exists())) {
      await rolePermissionCollection.create();
    }
  }

  getAllPermissions = async () => {
    const query = await db.query(
      aql`FOR permission IN ${permissionCollection} SORT permission._key DESC RETURN permission`,
    );

    const permissions = query.hasNext ? await query.all() : [];
     const groupedPermissions = permissions.reduce(async (acc, perm) => {
      const { moduleKey } = perm;
      if (!acc[moduleKey]) {
        acc[moduleKey] = {
          module: await moduleCollection.document(moduleKey),
          permissions: [],
        };
      }

      acc[moduleKey].permissions.push(perm);
      return acc;
    }, {});

    return Object.values(groupedPermissions);
  };

  //recuperer un permission avec son id
  getPermission = async ({ key }) => {
    try {
      return await permissionCollection.document(key);
    } catch {
      throw new Error(`La permission est introuvable`);
    }
  };
  //creer une nouvelle permission
  createPermission = async ({ libelle }) => {
    isValidValue({ value: libelle });
    const permission = {
      libelle: libelle,
    };
    try {
      await permissionCollection.save(permission);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de l'enregistrement");
    }
  };

  getPermissionByRole = async ({ roleKey }) => {
    try {
      if (!roleKey) return [];

      const query = await db.query(
        aql`FOR module IN ${moduleCollection} RETURN module`,
      );
      const allModules = query.hasNext ? await query.all() : [];
        const permCursor = await db.query(aql`
        FOR rolePermission IN ${rolePermissionCollection}
        FILTER rolePermission.roleKey == ${roleKey}
        RETURN rolePermission
      `);

      const rolePermissions = await permCursor.all();

      const modulesWithPermissions = await Promise.all(
        allModules.map(async (module) => {
          const modulePermissionsQuery = await db.query(
            aql`FOR permission IN permissions FILTER permission.moduleKey == ${module._key} OR permission.moduleId==${module._id} RETURN permission`,
          );
          const allPermissions = modulePermissionsQuery.hasNext
            ? await modulePermissionsQuery.all()
            : [];

          const permissionsWithCheck = allPermissions.map((perm) => {
            const isChecked = rolePermissions.some(
              (rolePerm) => rolePerm.permissionKey === perm._key,
            );
            return {
              ...perm,
              isChecked,
            };
          });

          return {
            module: module,
            permissions: permissionsWithCheck,
          };
        }),
      );

      return modulesWithPermissions;
    } catch (err) {
      console.error(err);

      console.error("Erreur lors de la récupération des permission");
      return [];
    }
  };

  getAllPermissionsByRoleForUser = async ({ roleKey }) => {
     try {
      const cursor = await db.query(aql`
        FOR rolePermission IN ${rolePermissionCollection }
        FILTER rolePermission.roleKey == ${roleKey}
        RETURN rolePermission
      `);
       const permissions = await cursor.all();
       const permissionsDetails = [];

      for (let i = 0; i < permissions.length; i++) {
        const perm = permissions[i];
         try {
 

  const permissionDetails = await permissionCollection.document(perm.permissionKey);


          if (permissionDetails.moduleKey) {
            try {
              const moduleDetails = await moduleCollection.document(
                permissionDetails.moduleKey,
              );
              permissionDetails.module = moduleDetails;
            } catch (moduleError) {
              console.error(
                `Erreur lors de la récupération du module ID: ${permissionDetails.moduleKey}`,
                moduleError,
              );
              permissionDetails.module = {
                id: permissionDetails.moduleKey,
                name: "Module inaccessible",
                alias: "MODULE_INCONNU",
                error: moduleError.message,
              };
            }
          }
          permissionsDetails.push(permissionDetails);
        } catch (permError) {
          console.error(
            `Erreur lors de la récupération de la permission ${perm.permissionKey}:`,
            permError,
          );
        }
      }
      return permissionsDetails;
    } catch (globalError) {
      console.error("Une erreur s'est survenue", globalError);
      throw globalError;
    }
  };
  isExistPermission = async ({ key }) => {
    const exist = await permissionCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette permission n'existe pas!");
    }
  };

  updatePermission = async ({ key, libelle }) => {
    let updateField = {};
    if (libelle !== undefined) {
      updateField.libelle = libelle;
    }
    try {
      await permissionCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la mise à jour");
    }
  };

  deletePermission = async ({ key }) => {
    try {
      const cursor = await db.query(aql`
        FOR rolePermission IN ${rolePermission }
        FILTER rolePermission.permissionKey == ${key}
        RETURN rolePermission
      `);
      const results = await cursor.all();
      if (results.length !== 0) {
        throw new Error("Suppression impossible");
      }
    } catch (err) {
      console.error(err);

      throw new Error("Suppression impossible");
    }
    try {
      await permissionCollection.remove(key);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la suppression");
    }
  };
}

export default Permission;
