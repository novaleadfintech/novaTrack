import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String?> getDownloadDirectoryPath() async {
  Directory? directory;

  if (Platform.isAndroid) {
    // Sur Android, obtenez le chemin du répertoire de stockage externe.
    directory = await getExternalStorageDirectory();

    // Ajoutez le sous-dossier de téléchargements.
    String downloadsPath = '${directory?.path}/Facture_SiNOVA';
    Directory downloadsDirectory = Directory(downloadsPath);

    // Créez le dossier de téléchargement s'il n'existe pas déjà.
    if (!downloadsDirectory.existsSync()) {
      downloadsDirectory.createSync(recursive: true);
    }

    return downloadsDirectory.path;
  } else if (Platform.isIOS) {
    // Sur iOS, utilisez simplement le répertoire des documents.
    directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  return null;
}
