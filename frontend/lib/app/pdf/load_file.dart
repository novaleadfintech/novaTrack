import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

Future<pw.ImageProvider> loadNetworkImage({required String url}) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    } else {
      throw 'Télechargement echoué. Vérifiez votre connexion internet et réessayez.';
    }
  } catch (e) {
    throw 'Télechargement echoué. Impossible de charger les images';
  }
}
