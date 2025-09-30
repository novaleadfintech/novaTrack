import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class PdfDownloadHelper {
  // Téléchargement pour le Web
  static void _downloadPdfForWeb(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;

    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  // Téléchargement pour Android/iOS en utilisant un fichier temporaire
  static Future<void> savePdfToMobile(Uint8List bytes, String fileName) async {
    try {
      if (kIsWeb) {
        _downloadPdfForWeb(bytes, fileName); // Web
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Obtenir le répertoire temporaire
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/$fileName';
        final tempFile = File(tempFilePath);

        // Écrire les données dans le fichier temporaire
        await tempFile.writeAsBytes(bytes);

        // Ouvrir le fichier temporaire (pour Android/iOS)
        await OpenFile.open(tempFilePath);
      } else {
        throw "Plateforme non supportée.";
      }
    } catch (e) {
      throw "Erreur lors du téléchargement : $e";
    }
  }

  // Téléchargement pour Windows avec fichier temporaire
  static Future<void> _downloadPdfForWindows(
      Uint8List bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/$fileName';
    final tempFile = File(tempFilePath);

    // Écrire les données dans le fichier temporaire
    await tempFile.writeAsBytes(bytes);

    // Ouvrir le fichier temporaire (Windows)
    await OpenFile.open(tempFilePath);
  }

  // Fonction principale pour déterminer où télécharger le fichier
  static Future<void> downloadPdf(
      {required Uint8List bytes, required String fileName}) async {
    if (kIsWeb) {
      _downloadPdfForWeb(bytes, fileName); // Web
    } else if (Platform.isAndroid || Platform.isIOS) {
      await savePdfToMobile(bytes, fileName); // Mobile
    } else if (Platform.isWindows) {
      await _downloadPdfForWindows(bytes, fileName); // Windows
    } else {
      throw "Plateforme non supportée.";
    }
  }
}
