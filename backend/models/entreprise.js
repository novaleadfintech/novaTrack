import { uploadFile, deleteFile } from "../utils/fichier.js";
import { aql } from "arangojs";
import db from "../db/database_connection.js";
import { isValidEmail, isValidValue } from "../utils/util.js";
import path from "path";

const entreprise = db.collection("entreprise");
const locateEntrepriseFolder = "entreprise";
import CountryModel from "./country.js";
const paysModel = new CountryModel();
class Entreprise {
  constructor() {}
  getEntreprise = async () => {
    const query = await db.query(
      aql`FOR info IN ${entreprise} LIMIT 1 RETURN info`
    );
    if (query.hasNext) {
      const info = await query.next();
      return {
        ...info,
        logo: info.logo
          ? process.env.FILE_PREFIX + `${locateEntrepriseFolder}/` + info.logo
          : null,
        tamponSignature: info.tamponSignature
          ? process.env.FILE_PREFIX +
            `${locateEntrepriseFolder}/` +
            info.tamponSignature
          : null,
      };
    }
    return null;
  };

  createEntreprise = async ({
    logo,
    adresse,
    email,
    telephone,
    ville,
    tamponSignature,
    nomDG,
    pays,
    raisonSociale,
  }) => {
    const newEntreprise = {};
    if (adresse !== undefined) newEntreprise.adresse = adresse;
    if (email !== undefined) {
      isValidEmail({ email });
      newEntreprise.email = email;
    }

    if (telephone !== undefined) newEntreprise.telephone = telephone;
    if (nomDG !== undefined) newEntreprise.nomDG = nomDG;
    if (raisonSociale !== undefined)
      newEntreprise.raisonSociale = raisonSociale;
    if (ville !== undefined) newEntreprise.ville = ville;
    if (pays !== undefined) {
      newEntreprise.pays = await paysModel.getCountry({ key: pays });
    }

    if (logo?.file !== undefined) {
      const { createReadStream, filename, mimetype } = await logo.file;
      if (filename) {
        const extension = path.extname(filename);
        const uniqueFilename = `logo${extension}`;

        const filePath = await uploadFile({
          createReadStream: createReadStream,
          locateFolder: locateEntrepriseFolder,
          mimetype: mimetype,
          uniquefilename: uniqueFilename,
        });

        if (!filePath) {
          throw new Error("Échec de l'upload du logo.");
        }
        newEntreprise.logo = filePath;
      }
    }

    // **Upload du tamponSignature**
    if (tamponSignature?.file !== undefined) {
      const { createReadStream, filename, mimetype } =
        await tamponSignature.file;
      if (filename) {
        const validName = "signature".replace(/ /g, "_");
        const extension = path.extname(filename);
        const uniqueFilename = `${validName}${extension}`;

        const filePath = await uploadFile({
          createReadStream,
          locateFolder: locateEntrepriseFolder,
          mimetype,
          uniquefilename: uniqueFilename,
        });

        if (!filePath) {
          throw new Error("Échec de l'upload de la signature.");
        }
        newEntreprise.tamponSignature = filePath;
      }
    }
    isValidValue({
      value: newEntreprise,
    });
    await entreprise.save(newEntreprise);
    return "OK";
  };

  updateEntreprise = async ({
    key,
    logo,
    adresse,
    email,
    ville,
    telephone,
    tamponSignature,
    nomDG,
    pays,
    raisonSociale,
  }) => {
    const updateField = {};
    const entre = await this.getEntreprise();

    if (entre == null) {
      await this.createEntreprise({
        adresse: adresse,
        email: email,
        logo: logo,
        nomDG: nomDG,
        tamponSignature: tamponSignature,
        telephone: telephone,
        pays: pays,
        raisonSociale: raisonSociale,
      });
      return "OK";
    }
    if (adresse !== undefined) {
      updateField.adresse = adresse;
    }
    if (email !== undefined) {
      isValidEmail({ email: email });
      updateField.email = email;
    }
    if (telephone !== undefined) {
      updateField.telephone = telephone;
    }
    if (nomDG !== undefined) {
      updateField.nomDG = nomDG;
    }
    if (ville !== undefined) {
      updateField.ville = ville;
    }
    if (pays !== undefined) {
      updateField.pays = await paysModel.getCountry({ key: pays });
    }
    if (raisonSociale !== undefined) {
      updateField.raisonSociale = raisonSociale;
    }

    // Gestion de l'update du logo
    try {
      if (logo?.file !== undefined) {
        const { createReadStream, filename, mimetype } = await logo.file;
        if (filename) {
          const oldLogo = entreprise.logo;
          let uniquefilename;

          if (oldLogo) {
            const oldFilePath = oldLogo;
            const oldFileExtension = path.extname(oldFilePath);
            const newFileExtension = path.extname(filename);
            const trueOldFilePath = oldFilePath.replace(
              process.env.FILE_PREFIX,
              ""
            );

            if (newFileExtension !== oldFileExtension) {
              deleteFile({
                filePath: oldFilePath.replace(process.env.FILE_PREFIX, ""),
              });
            }
            uniquefilename = trueOldFilePath.replace(
              oldFileExtension,
              newFileExtension
            );
          } else {
            const valid_name = "logo".replace(/ /g, "_");
            const extension = path.extname(filename);
            uniquefilename = `${valid_name}${extension}`;
          }

          updateField.logo = await uploadFile({
            createReadStream: createReadStream,
            locateFolder: locateEntrepriseFolder,
            mimetype: mimetype,
            uniquefilename: uniquefilename,
          });

          if (!updateField.logo) {
            throw new Error("Échec de l'upload du fichier logo.");
          }
        }
      }
    } catch (e) {
      throw error;
    }

    if (tamponSignature?.file !== undefined) {
      const { createReadStream, filename, mimetype } =
        await tamponSignature.file;
      if (filename) {
        const oldTampon = entreprise.tamponSignature;
        let uniquefilename;

        if (oldTampon) {
          const oldFilePath = oldTampon;
          const oldFileExtension = path.extname(oldFilePath);
          const newFileExtension = path.extname(filename);
          const trueOldFilePath = oldFilePath.replace(
            process.env.FILE_PREFIX,
            ""
          );

          if (newFileExtension !== oldFileExtension) {
            deleteFile({
              filePath: oldFilePath.replace(process.env.FILE_PREFIX, ""),
            });
          }
          uniquefilename = trueOldFilePath.replace(
            oldFileExtension,
            newFileExtension
          );
        } else {
          const valid_name = "signature".replace(/ /g, "_");
          const extension = path.extname(filename);
          uniquefilename = `${valid_name}${extension}`;
        }

        updateField.tamponSignature = await uploadFile({
          createReadStream: createReadStream,
          locateFolder: locateEntrepriseFolder,
          mimetype: mimetype,
          uniquefilename: uniquefilename,
        });

        if (!updateField.tamponSignature) {
          throw new Error("Échec de l'upload de la signature.");
        }
      }
    }
    isValidValue({
      value: updateField,
    });

    await entreprise.update(key, updateField);
    return "OK";
  };
}

export default Entreprise;
