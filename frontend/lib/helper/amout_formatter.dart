import 'package:intl/intl.dart';

class Formatter {
static String formatAmount(double amount) {
    String amountStr = amount.toString();

    // Séparer la partie entière et décimale
    List<String> parts = amountStr.split('.');

    // Formatter la partie entière avec espaces pour les milliers
    String intFormatted = NumberFormat('#,##0', 'en_US')
        .format(int.parse(parts[0]))
        .replaceAll(',', ' ');

    // Afficher la partie décimale seulement si elle contient autre chose que des zéros
    if (parts.length > 1 && RegExp(r'[1-9]').hasMatch(parts[1])) {
      return '$intFormatted.${parts[1]}';
  }

    return intFormatted;
  }
  

  static String parseAmount(String formattedAmount) {
    return formattedAmount.replaceAll(RegExp(r'[\s,]'), '');
  }
}
