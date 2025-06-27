String getStringDate({required DateTime time}) {
  final day = time.day == 1 ? '1er' : '${time.day}';
  return '$day ${months[time.month - 1]} ${time.year}';
}


String getShortStringDate({required DateTime time}) {
  const List<String> months = [
    "jan",
    "fév",
    "mars",
    "avr",
    "mai",
    "juin",
    "juil",
    "août",
    "sep",
    "oct",
    "nov",
    "déc",
  ];
  return '${time.day} ${months[time.month - 1]} ${time.year}';
}

String duration({required DateTime date}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day); 
  final comparisonDate =
      DateTime(date.year, date.month, date.day); 
  final difference = comparisonDate.difference(today);

  String pluralize(int value, String singular, String plural) {
    return value == 1 ? singular : plural;
  }

  if (difference.inDays == 0) {
    return "Aujourd'hui";
  } else if (difference.inDays == -1) {
    return "Hier";
  } else if (difference.inDays == 1) {
    return "Demain";
  } else if (difference.isNegative) {
    final absDifference = difference.abs();
    final days = absDifference.inDays;

    if (days < 7) {
      return "Il y a $days ${pluralize(days, 'jour', 'jours')}";
    } else if (days < 30) {
      final weeks = days ~/ 7;
      return "Il y a $weeks ${pluralize(weeks, 'semaine', 'semaines')}";
    } else if (days < 365) {
      final months = days ~/ 30;
      return "Il y a $months ${pluralize(months, 'mois', 'mois')}";
    } else {
      final years = days ~/ 365;
      return "Il y a $years ${pluralize(years, 'année', 'années')}";
    }
  } else {
    final days = difference.inDays;

    if (days < 7) {
      return "Dans $days ${pluralize(days, 'jour', 'jours')}";
    } else if (days < 30) {
      final weeks = days ~/ 7;
      return "Dans $weeks ${pluralize(weeks, 'semaine', 'semaines')}";
    } else if (days < 365) {
      final months = days ~/ 30;
      return "Dans $months ${pluralize(months, 'mois', 'mois')}";
    } else {
      final years = days ~/ 365;
      return "Dans $years ${pluralize(years, 'année', 'années')}";
    }
  }
}

String formatPeriodePaiement({required DateTime dateEdition}) {
  List<String> mois = months;

  String moisString = mois[dateEdition.month - 1];
  String annee = dateEdition.year.toString();

  return '$moisString $annee';
}

String shortDuration({required DateTime date}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final comparisonDate = DateTime(date.year, date.month, date.day);
  final difference = comparisonDate.difference(today);

  if (difference.inDays == 0) {
    return "Auj";
  } else if (difference.inDays == -1) {
    return "Hier";
  } else if (difference.inDays == 1) {
    return "Dem";
  } else if (difference.isNegative) {
    final absDifference = difference.abs();
    if (absDifference.inDays < 7) {
      return "- ${absDifference.inDays} jr${absDifference.inDays > 1 ? 's' : ''}";
    } else if (absDifference.inDays < 30) {
      return "- ${absDifference.inDays ~/ 7} sem${absDifference.inDays ~/ 7 > 1 ? 's' : ''}";
    } else if (absDifference.inDays < 365) {
      return "- ${absDifference.inDays ~/ 30} mois${absDifference.inDays ~/ 30 > 1 ? 's' : ''}";
    } else {
      return "- ${absDifference.inDays ~/ 365} an${absDifference.inDays ~/ 365 > 1 ? 's' : ''}";
    }
  } else {
    if (difference.inDays < 7) {
      return "+ ${difference.inDays} jr${difference.inDays > 1 ? 's' : ''}";
    } else if (difference.inDays < 30) {
      return "+ ${difference.inDays ~/ 7} sem${difference.inDays ~/ 7 > 1 ? 's' : ''}";
    } else if (difference.inDays < 365) {
      return "+ ${difference.inDays ~/ 30} mois${difference.inDays ~/ 30 > 1 ? 's' : ''}";
    } else {
      return "+ ${difference.inDays ~/ 365} an${difference.inDays ~/ 365 > 1 ? 's' : ''}";
    }
  }
}

class DurationRepresentation {
  final int compteur;
  final String unite;

  DurationRepresentation({
    required this.compteur,
    required this.unite,
  });
}

// Multiplicateurs pour les unités de temps
final Map<String, int> unitMultipliers = {
  'années': 365 * 24 * 60 * 60 * 1000,
  'mois': 30 * 24 * 60 * 60 * 1000,
  'semaines': 7 * 24 * 60 * 60 * 1000,
  'jours': 24 * 60 * 60 * 1000,
  'heures': 60 * 60 * 1000,
  'minutes': 60 * 1000,
  'secondes': 1000,
  'millisecondes': 1,
};

DurationRepresentation convertDuration({required int durationMs}) {
  for (var entry in unitMultipliers.entries) {
    final int multiplier = entry.value;
    if (durationMs >= multiplier) {
      final int compteur = durationMs ~/ multiplier;
      return DurationRepresentation(
        compteur: compteur,
        unite: entry.key,
      );
    }
  }

  // Si la durée est inférieure à 1 milliseconde
  return DurationRepresentation(
    compteur: durationMs,
    unite: 'millisecondes',
  );
}

String formatDate({required DateTime dateTime}) {
  final day =
      dateTime.day.toString().padLeft(2, '0'); // Ajoute un '0' si nécessaire
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  return "$day/$month/$year";
}

String getNextMonthDate({required DateTime dateTime}) {
  // Ajoute un mois tout en gérant les dépassements
  DateTime nextMonth = DateTime(
    dateTime.year,
    dateTime.month + 1,
    dateTime.day,
  );

  // Si le jour dépasse les jours valides du mois suivant, ajuste au dernier jour valide
  if (nextMonth.month > (dateTime.month % 12) + 1) {
    nextMonth = DateTime(
      nextMonth.year,
      nextMonth.month,
      0, // Jour 0 renvoie au dernier jour du mois précédent
    );
  }

  // Formate la date
  final day = nextMonth.day.toString().padLeft(2, '0');
  final month = nextMonth.month.toString().padLeft(2, '0');
  final year = nextMonth.year.toString();

  return "$day/$month/$year";
}

const List<String> months = [
  "janvier",
  "février",
  "mars",
  "avril",
  "mai",
  "juin",
  "juillet",
  "août",
  "septembre",
  "octobre",
  "novembre",
  "décembre",
];

DateTime convertToDateTime(String dateString) {
  // Séparer la chaîne en jour, mois et année
  final parts = dateString.split(' ');

  if (parts.length != 3) {
    throw FormatException("La date n'est pas dans le format attendu.");
  }

  final day = int.parse(parts[0]);
  final month = months.indexOf(parts[1].toLowerCase()) +
      1; // Trouver le mois correspondant
  final year = int.parse(parts[2]);

  return DateTime(year, month, day);
}


