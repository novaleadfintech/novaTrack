String convertNumberToWords(num number) {
  // Séparer la partie entière et la partie décimale
  int integerPart = number.toInt();
  int decimalPart = ((number - integerPart) * 100).round();

  // Convertir la partie entière en lettres
  String integerPartInWords = _convertIntegerToWords(integerPart);

  // Convertir la partie décimale en lettres, si elle existe
  String decimalPartInWords = "";
  if (decimalPart > 0) {
    decimalPartInWords = _convertIntegerToWords(decimalPart);
  }

  // Combiner les deux parties
  if (decimalPartInWords.isNotEmpty) {
    return "$integerPartInWords virgule $decimalPartInWords";
  } else {
    return integerPartInWords;
  }
}

// Fonction privée pour convertir la partie entière en lettres
String _convertIntegerToWords(int number) {
  final List<String> units = [
    "zéro",
    "un",
    "deux",
    "trois",
    "quatre",
    "cinq",
    "six",
    "sept",
    "huit",
    "neuf"
  ];
  final List<String> teens = [
    "dix",
    "onze",
    "douze",
    "treize",
    "quatorze",
    "quinze",
    "seize",
    "dix-sept",
    "dix-huit",
    "dix-neuf"
  ];
  final List<String> tens = [
    "",
    "",
    "vingt",
    "trente",
    "quarante",
    "cinquante",
    "soixante",
    "soixante",
    "quatre-vingt",
    "quatre-vingt"
  ];

  String words = "";

  if (number == 0) {
    return units[0];
  }

  if (number >= 1000000000) {
    int billions = number ~/ 1000000000;
    words +=
        "${_convertIntegerToWords(billions)} milliard${billions > 1 ? 's' : ''} ";
    number %= 1000000000;
  }

  if (number >= 1000000) {
    int millions = number ~/ 1000000;
    words +=
        "${_convertIntegerToWords(millions)} million${millions > 1 ? 's' : ''} ";
    number %= 1000000;
  }

  if (number >= 1000) {
    int thousands = number ~/ 1000;
    if (thousands > 1) {
      words += "${_convertIntegerToWords(thousands)} mille ";
    } else {
      words += "mille ";
    }
    number %= 1000;
  }

  if (number >= 100) {
    int hundreds = number ~/ 100;
    if (hundreds > 1) {
      words += "${units[hundreds]} cent";
      if (number % 100 == 0) {
        words += "s";
      }
      words += " ";
    } else {
      words += "cent ";
    }
    number %= 100;
  }

  if (number >= 20) {
    int tensValue = number ~/ 10;
    int remainder = number % 10;

    if (tensValue == 7 || tensValue == 9) {
      words += tens[tensValue - 1];
      if (remainder > 0) {
        words += "-${teens[remainder]}";
      }
    } else {
      words += tens[tensValue];
      if (remainder == 1 && (tensValue != 8)) {
        words += "-et-un";
      } else if (remainder > 0) {
        words += "-${units[remainder]}";
      }
    }
  } else if (number >= 10) {
    words += teens[number - 10];
  } else if (number > 0) {
    words += units[number];
  }

  return words.trim();
}
