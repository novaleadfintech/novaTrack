import dotenv from "dotenv";
import path from "path";
import fs from "fs";

dotenv.config();

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 kB

const uploadFile = async ({
  createReadStream,
  uniquefilename,
  locateFolder,
}) => {
  const currentDir = process.cwd();

  const uploadDir = path.join(currentDir, "public", locateFolder);

  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
  }

  const filePath = path.join(uploadDir, uniquefilename);

  // Créer un stream pour lire le fichier et vérifier la taille
  const stream = createReadStream();
  let fileSize = 0;

  return new Promise((resolve, reject) => {
    stream.on("data", (chunk) => {
      fileSize += chunk.length;

      // Si la taille du fichier dépasse la limite, arrêter le stream et renvoyer une erreur
      if (fileSize > MAX_FILE_SIZE) {
        stream.destroy();
        reject(
          new Error("Le fichier dépasse la taille maximale autorisée de 10 Mo")
        );
      }
    });

    const writeStream = fs.createWriteStream(filePath);

    stream
      .pipe(writeStream)
      .on("finish", () => resolve(uniquefilename))
      .on("error", (error) => reject(error));
  });
};

const deleteFile = ({ filePath }) => {
  try {
    fs.unlinkSync(filePath);
  } catch (err) {
    console.error(err);

    console.error("Erreur lors de la suppression de l'ancien fichier");
  }
};

export { uploadFile, deleteFile };
