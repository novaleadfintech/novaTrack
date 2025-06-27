import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";


const permissionCollection = db.collection("permissions");
const moduleCollection = db.collection("modules");
const rolePermissionEdges = db.collection("rolePermissions");

class Permission {
  constructor() {}

  getAllPermissions = async () => {
    const query = await db.query(
      aql`FOR permission IN ${permissionCollection} SORT permission._key DESC RETURN permission`
    );

    const permissions = query.hasNext ? await query.all() : [];

    const groupedPermissions = permissions.reduce(async (acc, perm) => {
      const { moduleId } = perm;
      if (!acc[moduleId]) {
        acc[moduleId] = {
          module: await moduleCollection.document(moduleId),
          permissions: [],
        };
      }

      acc[moduleId].permissions.push(perm);
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

  getPermissionByRole = async ({ roleId }) => {
    try {
      if (!roleId) return [];

      const query = await db.query(
        aql`FOR module IN ${moduleCollection} RETURN module`
      );
      const allModules = query.hasNext ? await query.all() : [];

      const results = await rolePermissionEdges.edges(roleId);
      const rolePermissions = results?.edges || [];

      const modulesWithPermissions = await Promise.all(
        allModules.map(async (module) => {
          const modulePermissionsQuery = await db.query(
            aql`FOR permission IN permissions FILTER permission.moduleId == ${module._id} RETURN permission`
          );
          const allPermissions = modulePermissionsQuery.hasNext
            ? await modulePermissionsQuery.all()
            : [];

          const permissionsWithCheck = allPermissions.map((perm) => {
            const isChecked = rolePermissions.some(
              (rolePerm) => rolePerm._to === perm._id
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
        })
      );

      return modulesWithPermissions;
    } catch (err) {
      console.error("Erreur lors de la récupération des permissions :", err);
      return [];
    }
  };

  getAllPermissionsByRoleForUser = async ({ roleId }) => {
    try {
      const results = await rolePermissionEdges.edges(roleId);
      const permissions = results.edges;

      const permissionsDetails = [];

      for (let i = 0; i < permissions.length; i++) {
        const perm = permissions[i];
        try {
          const permissionDetails = await permissionCollection.document(
            perm._to
          );

          if (permissionDetails.moduleId) {
            try {
              const moduleDetails = await moduleCollection.document(
                permissionDetails.moduleId
              );
              permissionDetails.module = moduleDetails;
            } catch (moduleError) {
              console.error(
                `Erreur lors de la récupération du module ID: ${permissionDetails.moduleId}`,
                moduleError
              );
              permissionDetails.module = {
                id: permissionDetails.moduleId,
                name: "Module inaccessible",
                alias: "MODULE_INCONNU",
                error: moduleError.message,
              };
            }
          }
          permissionsDetails.push(permissionDetails);
        } catch (permError) {
          console.error(
            `Erreur lors de la récupération de la permission ${perm._to}:`,
            permError
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
      throw new Error("Erreur lors de la mise à jour");
    }
  };

  deletePermission = async ({ key }) => {
    try {
      const results = await rolePermissionEdges.edges(key);
      if (results.edges.length !== 0) {
        throw new Error("Suppression impossible");
      }
    } catch (err) {
      throw new Error(err);
    }
    try {
      await permissionCollection.remove(key);
      return "OK";
    } catch (err) {
      throw new Error("Erreur lors de la suppression");
    }
  };
}

export default Permission;
