import 'package:flutter/foundation.dart';
import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'dart:io' show Platform;

Future<bool> isLinkOnline(Uri url) async {
  try {
    final response = await http.head(url);
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<void> openFile({required String name}) async {
  final url = Uri.parse(name);

  try {
    if (await isLinkOnline(url)) {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);

        throw "Impossible d'ouvrir le fichier";
      }
    } else {
      final result = await OpenFile.open(name);
      if (result.type != ResultType.done) {
        throw "Impossible d'ouvrir le fichier local";
      }
    }
  } catch (e) {
    MutationRequestContextualBehavior.showPopup(
      status: PopupStatus.customError,
      customMessage: e.toString(),
    );
  }
}

bool isMobileDevice() {
  if (kIsWeb) {
    return false;
  } else {
    return Platform.isAndroid || Platform.isIOS;
  }
}

String getFileType(String filePath) {
  if (filePath.endsWith('.jpg') ||
      filePath.endsWith('.png') ||
      filePath.endsWith('.jpeg')) {
    return 'image';
  } else if (filePath.endsWith('.pdf')) {
    return 'pdf';
  }
  return 'unknown';
}
