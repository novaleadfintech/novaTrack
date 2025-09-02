import '../model/bulletin_paie/rubrique.dart';
import '../model/bulletin_paie/salarie_model.dart';
import '../model/bulletin_paie/type_rubrique.dart';

import '../model/bulletin_paie/nature_rubrique.dart';
import '../model/bulletin_paie/rubrique_paie.dart';
import '../model/bulletin_paie/tranche_model.dart';

List<DateTime>? getCurrentBulletinPeriod({
  required SalarieModel salarie,
  required DateTime? debutOldPeriodePaie,
  required DateTime? finOldPeriodePaie,
}) {
  print(debutOldPeriodePaie);
  print(finOldPeriodePaie);
  final DateTime dateDebut = salarie.personnel.dateDebut!;
  final DateTime finEssai =
      dateDebut.add(Duration(milliseconds: salarie.personnel.dureeEssai ?? 0));
  final DateTime dateFin = salarie.personnel.dateFin ?? DateTime.now();
  final DateTime now = DateTime.now();

  final int? frequenceMs = salarie.periodPaie;

  // Aucun paiement périodique
  if (frequenceMs == null || frequenceMs <= 0) {
    return null;
  }

  final int frequenceMois =
      (frequenceMs / Duration(days: 30).inMilliseconds).round();
  if (frequenceMois <= 0) return null;

  final bool isEndOfMonth = salarie.paieManner == PaieManner.finMois;

  // Si les anciennes périodes sont nulles, utiliser la logique basée sur la date actuelle
  if (debutOldPeriodePaie == null || finOldPeriodePaie == null) {
    return _getCurrentPeriodBasedOnNow(salarie, dateDebut, finEssai, dateFin,
        now, frequenceMois, isEndOfMonth);
  }

  // Calculer la période suivant l'ancienne période
  DateTime nouvellePeriodeDebut;
  DateTime nouvellePeriodeFin;

  if (isEndOfMonth) {
    // Mode fin de mois : périodes du 1er au dernier jour du mois

    // La nouvelle période commence le 1er jour du mois suivant la fin de l'ancienne période
    nouvellePeriodeDebut = DateTime(
      finOldPeriodePaie.year,
      finOldPeriodePaie.month + 1,
      1,
    );

    // La nouvelle période se termine le dernier jour du mois (en tenant compte de la fréquence)
    nouvellePeriodeFin = DateTime(
      nouvellePeriodeDebut.year,
      nouvellePeriodeDebut.month + frequenceMois,
      1,
    ).subtract(const Duration(days: 1));
  } else if (salarie.paieManner == PaieManner.finPeriod) {
    // Mode fin de période : même jour du mois que la date de début
    final int jourDuMois = dateDebut.day;

    // La nouvelle période commence le jour suivant la fin de l'ancienne période
    nouvellePeriodeDebut = finOldPeriodePaie.add(const Duration(days: 1));

    // Ajuster le début au bon jour du mois si nécessaire
    if (nouvellePeriodeDebut.day != jourDuMois) {
      // Aller au prochain occurrence du jour du mois
      int moisCible = nouvellePeriodeDebut.month;
      int anneeCible = nouvellePeriodeDebut.year;

      // Si le jour est déjà passé dans le mois courant, aller au mois suivant
      if (nouvellePeriodeDebut.day > jourDuMois) {
        moisCible++;
        if (moisCible > 12) {
          moisCible = 1;
          anneeCible++;
        }
      }

      nouvellePeriodeDebut = DateTime(anneeCible, moisCible, jourDuMois);
    }

    // La nouvelle période se termine avant le même jour du mois suivant (en tenant compte de la fréquence)
    nouvellePeriodeFin = DateTime(
      nouvellePeriodeDebut.year,
      nouvellePeriodeDebut.month + frequenceMois,
      jourDuMois,
    ).subtract(const Duration(days: 1));
  } else {
    return null;
  }

  // Vérifier que la nouvelle période commence après la fin d'essai
  if (nouvellePeriodeDebut.isBefore(finEssai)) {
    nouvellePeriodeDebut = finEssai;
  }

  // Vérifier que la nouvelle période ne dépasse pas la date de fin du contrat
  if (nouvellePeriodeDebut.isAfter(dateFin)) {
    return null; // Pas de période suivante possible
  }

  // Ajuster la fin de période si elle dépasse la date de fin du contrat
  if (nouvellePeriodeFin.isAfter(dateFin)) {
    nouvellePeriodeFin = dateFin;
  }

  // Vérifier que la nouvelle période ne dépasse pas la date actuelle de manière excessive
  // (par exemple, ne pas générer une période qui commence dans plus de 2 mois)
  if (nouvellePeriodeDebut.isAfter(now.add(const Duration(days: 60)))) {
    return null; // Période trop dans le futur
  }

  return [nouvellePeriodeDebut, nouvellePeriodeFin];
}

// Fonction helper pour la logique basée sur la date actuelle (logique d'origine)
List<DateTime>? _getCurrentPeriodBasedOnNow(
  SalarieModel salarie,
  DateTime dateDebut,
  DateTime finEssai,
  DateTime dateFin,
  DateTime now,
  int frequenceMois,
  bool isEndOfMonth,
) {
  if (isEndOfMonth) {
    // Mode fin de mois : périodes du 1er au dernier jour du mois

    // Première période : de la fin d'essai jusqu'à la fin du mois
    DateTime premierePeriodeDebut = finEssai;
    DateTime premierePeriodeFin = DateTime(finEssai.year, finEssai.month + 1, 1)
        .subtract(const Duration(days: 1)); // Dernier jour du mois

    // Si on est encore dans la première période
    if (now.isAfter(premierePeriodeDebut.subtract(const Duration(days: 1))) &&
        now.isBefore(premierePeriodeFin.add(const Duration(days: 1)))) {
      return [
        premierePeriodeDebut,
        premierePeriodeFin.isAfter(dateFin) ? dateFin : premierePeriodeFin,
      ];
    }

    // Périodes suivantes : du 1er au dernier jour de chaque mois
    DateTime periodeDebut = DateTime(finEssai.year, finEssai.month + 1, 1);

    while (periodeDebut.isBefore(dateFin) ||
        periodeDebut.isAtSameMomentAs(dateFin)) {
      DateTime periodeFin = DateTime(
        periodeDebut.year,
        periodeDebut.month + frequenceMois,
        1,
      ).subtract(const Duration(days: 1));

      // Vérifier si on est dans cette période
      if (now.isAfter(periodeDebut.subtract(const Duration(days: 1))) &&
          now.isBefore(periodeFin.add(const Duration(days: 1)))) {
        return [
          periodeDebut,
          periodeFin.isAfter(dateFin) ? dateFin : periodeFin,
        ];
      }

      // Avancer à la période suivante
      periodeDebut = DateTime(
        periodeDebut.year,
        periodeDebut.month + frequenceMois,
        1,
      );
    }
  } else if (salarie.paieManner == PaieManner.finPeriod) {
    // Mode fin de période : même jour du mois que la date de début
    final int jourDuMois = dateDebut.day;

    DateTime currentStart = finEssai;

    while (currentStart.isBefore(dateFin) ||
        currentStart.isAtSameMomentAs(dateFin)) {
      DateTime currentEnd = DateTime(
        currentStart.year,
        currentStart.month + frequenceMois,
        jourDuMois,
      ).subtract(const Duration(days: 1));

      // Vérifier si on est dans cette période
      if (now.isAfter(currentStart.subtract(const Duration(days: 1))) &&
          now.isBefore(currentEnd.add(const Duration(days: 1)))) {
        return [
          currentStart,
          currentEnd.isAfter(dateFin) ? dateFin : currentEnd,
        ];
      }

      // Avancer à la période suivante
      currentStart = DateTime(
        currentStart.year,
        currentStart.month + frequenceMois,
        jourDuMois,
      );
    }
  }

  return null;
}

List<List<DateTime>> getBulletinPeriods({required SalarieModel salarie}) {
  final List<List<DateTime>> periods = [];

  final DateTime dateDebut = salarie.personnel.dateDebut!;
  final DateTime finEssai =
      dateDebut.add(Duration(milliseconds: salarie.personnel.dureeEssai ?? 0));
  final DateTime dateFin = salarie.personnel.dateFin ?? DateTime.now();

  final int frequenceMs = salarie.periodPaie ?? 0;

  // Calcul de la fréquence en mois
  final int frequenceMois =
      (frequenceMs / Duration(days: 30).inMilliseconds).round();
  if (frequenceMois <= 0) {
    throw 'La fréquence de paie doit être supérieure à 0 mois.';
  }

  // Vérification du mode de paiement
  final bool isEndOfMonth = salarie.paieManner == PaieManner.finMois;

  if (isEndOfMonth) {
    // ----- Cas 1 : Paiement à la fin du mois -----

    // Début de la période = fin de la période d'essai
    DateTime currentStart = finEssai;
    // Calcule la fin du premier mois après finEssai (dernier jour du mois)
    DateTime endOfFirstMonth = DateTime(
      currentStart.year,
      currentStart.month + 1,
    ).subtract(Duration(days: 1));

    // Ajoute la première période [finEssai → fin du mois]
    periods.add([currentStart, endOfFirstMonth]);

    // Prépare le début de la prochaine période : premier jour du mois suivant
    currentStart = DateTime(endOfFirstMonth.year, endOfFirstMonth.month + 1, 1);
    // saute au mois suivant (sécurité)

    // Boucle pour générer les périodes suivantes jusqu'à dateFin
    while (currentStart.isBefore(dateFin)) {
      // Calcule la fin de la période courante : dernier jour après `frequenceMois` mois
      DateTime currentEnd = DateTime(
        currentStart.year,
        currentStart.month + frequenceMois,
        0, // 0 = dernier jour du mois précédent, donc le dernier jour du bon mois
      );
      // Si la fin dépasse la date de fin globale, on coupe à dateFin
      if (currentEnd.isAfter(dateFin)) {
        currentEnd = dateFin;
      }

      // Ajoute la pérsiode au tableau
      periods.add([currentStart, currentEnd]);

      // Avance au mois suivant (au 1er jour)
      currentStart = DateTime(currentEnd.year, currentEnd.month, 1)
          .add(const Duration(days: 32));
      currentStart = DateTime(currentStart.year, currentStart.month, 1);
    }
  } else if (salarie.paieManner == PaieManner.finPeriod) {
    final int jourDuMois = dateDebut.day;

    DateTime currentStart = finEssai;

    DateTime nextAlignedEnd = DateTime(
      currentStart.year,
      currentStart.month,
      jourDuMois,
    );

    if (nextAlignedEnd.isBefore(currentStart)) {
      nextAlignedEnd = DateTime(
        currentStart.year,
        currentStart.month + 1,
        jourDuMois,
      );
    }

    periods.add(
      [currentStart, nextAlignedEnd.subtract(const Duration(days: 1))],
    );

    currentStart = nextAlignedEnd;

    while (currentStart.isBefore(dateFin)) {
      DateTime currentEnd = DateTime(
        currentStart.year,
        currentStart.month + frequenceMois,
        jourDuMois,
      );

      if (currentEnd.isAfter(dateFin)) {
        currentEnd = dateFin;
      }

      periods.add(
        [currentStart, currentEnd.subtract(const Duration(days: 1))],
      );
      currentStart = currentEnd;
    }
  }

  return periods;
}

int countValidPeriodsRestant({required SalarieModel salarie}) {
  final List<List<DateTime>> periods = getBulletinPeriods(salarie: salarie);
  if (periods.isEmpty) return 0;
  final int frequenceMs = salarie.periodPaie ?? 0;
  final DateTime now = DateTime.now();

  // Trouver l'index de la période contenant la date d'aujourd'hui
  int startIndex = -1;

  for (int i = 0; i < periods.length; i++) {
    final start = periods[i][0];
    final end = periods[i][1];

    if (!now.isBefore(start) && !now.isAfter(end)) {
      startIndex = i;
      break;
    }
  }

  if (startIndex == -1) {
    return 0;
  }

  // Compter les périodes valides (durée exacte) à partir de celle trouvée
  int count = 0;
  for (int i = startIndex; i < periods.length; i++) {
    final start = periods[i][0];
    final end = periods[i][1];
    final durationMs =
        end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    if (durationMs >= frequenceMs) {
      count++;
    }
  }
  return count;
}

class RubriqueCalculator {
  // Method to calculate rubriques in the correct dependency order
  static List<RubriqueOnBulletinModel> calculateRubriquesWithDependencies(
    List<RubriqueOnBulletinModel> rubriques,
  ) {
    // Create a map to track dependencies
    final dependencyMap = <String, Set<String>>{};

    // Build dependency graph
    for (var rubrique in rubriques) {
      dependencyMap[rubrique.rubrique.code] =
          findDependencies(rubrique, rubriques);
    }

    // Topological sort to order rubriques
    final orderedRubriques = _topologicalSort(dependencyMap, rubriques);

    // Calculate values for each rubrique in order
    for (var rubrique in orderedRubriques) {
      rubrique.value = calculerMontantRubrique(
        rubriqueOnBulletin: rubrique,
        toutesLesRubriquesSurBulletin: rubriques,
      );
    }

    return rubriques;
  }

  // Find direct dependencies for a rubrique
  static Set<String> findDependencies(
    RubriqueOnBulletinModel rubrique,
    List<RubriqueOnBulletinModel> allRubriques,
  ) {
    final dependencies = <String>{};

    switch (rubrique.rubrique.nature) {
      case NatureRubrique.taux:
        // Add base rubrique for taux calculation
        if (rubrique.rubrique.taux?.base != null) {
          dependencies.add(rubrique.rubrique.taux!.base.code);
        }
        break;

      case NatureRubrique.calcul:
        // Add rubriques used in calculation
        for (var element in rubrique.rubrique.calcul?.elements ?? []) {
          if (element.type == BaseType.rubrique) {
            dependencies.add(element.rubrique!.code);
          }
        }
        break;

      case NatureRubrique.sommeRubrique:
        // Add rubriques used in sum
        for (var element in rubrique.rubrique.sommeRubrique?.elements ?? []) {
          if (element.type == BaseType.rubrique) {
            dependencies.add(element.rubrique!.code);
          }
        }
        break;

      case NatureRubrique.bareme:
        // Add reference rubrique for bareme calculation
        if (rubrique.rubrique.bareme?.reference != null) {
          dependencies.add(rubrique.rubrique.bareme!.reference.code);
        }
        break;

      case NatureRubrique.constant:
        // No dependencies
        break;
    }
    return dependencies;
  }

  // Topological sort to resolve calculation order
  static List<RubriqueOnBulletinModel> _topologicalSort(
    Map<String, Set<String>> dependencyMap,
    List<RubriqueOnBulletinModel> rubriques,
  ) {
    final visited = <String>{};
    final result = <RubriqueOnBulletinModel>[];

    void dfs(RubriqueOnBulletinModel rubrique) {
      final code = rubrique.rubrique.code;

      if (visited.contains(code)) return;

      // Recursively process dependencies first
      for (var dependency in dependencyMap[code] ?? {}) {
        final depRubrique = rubriques.firstWhere(
          (r) => r.rubrique.code == dependency,
          orElse: () => throw ArgumentError(
            'Il existe une rubrique dependant d\'une rubrique qui n\'existe pas',
          ),
        );

        if (!visited.contains(dependency)) {
          dfs(depRubrique);
        }
      }

      // Mark as visited and add to result
      visited.add(code);
      result.add(rubrique);
    }

    // Process each rubrique that hasn't been visited
    for (var rubrique in rubriques) {
      if (!visited.contains(rubrique.rubrique.code)) {
        dfs(rubrique);
      }
    }

    return result;
  }

  // Your existing calculerMontantRubrique method would go here
  // (Copied from the original implementation)
  static double calculerMontantRubrique({
    required RubriqueOnBulletinModel rubriqueOnBulletin,
    required List<RubriqueOnBulletinModel> toutesLesRubriquesSurBulletin,
  }) {
    RubriqueBulletin rubrique = rubriqueOnBulletin.rubrique;
    switch (rubrique.nature) {
      case NatureRubrique.constant:
        return rubriqueOnBulletin.value ?? 0;

      case NatureRubrique.taux:
        final double taux = rubrique.taux!.taux;

        final baseRubrique = toutesLesRubriquesSurBulletin.firstWhere(
          (el) => el.rubrique.code == rubrique.taux!.base.code,
          orElse: () => RubriqueOnBulletinModel(
            rubrique: rubrique.taux!.base,
            value: 0,
          ),
        );

        final double base = baseRubrique.value ?? 0;
        return taux * base / 100;

      case NatureRubrique.calcul:
        final op = rubrique.calcul!.operateur;
        final rubriquesCible = rubrique.calcul!.elements;
        final valeurs = rubriquesCible.map((element) {
          if (element.type == BaseType.rubrique) {
            final r = toutesLesRubriquesSurBulletin.firstWhere(
              (toElement) => toElement.rubrique.code == element.rubrique!.code,
              orElse: () => RubriqueOnBulletinModel(
                  rubrique: element.rubrique!, value: 0),
            );
            return r.value;
          } else if (element.type == BaseType.valeur) {
            return element.valeur;
          }
        }).toList();

        if (valeurs.isEmpty) return 0;

        double result = valeurs[0]!;
        switch (op) {
          case Operateur.addition:
            result += valeurs[1]!;
            break;
          case Operateur.soustraction:
            result -= valeurs[1]!;
            break;
          case Operateur.multiplication:
            result *= valeurs[1]!;
            break;
          case Operateur.division:
            result /= valeurs[1] == 0 ? 1 : valeurs[1]!;
            break;
        }

        return result;

      case NatureRubrique.sommeRubrique:
        final rubriquesCible = rubrique.sommeRubrique!.elements;
        List valeurs = rubriquesCible.map((element) {
          if (element.type == BaseType.rubrique) {
            final match = toutesLesRubriquesSurBulletin.firstWhere(
              (toElement) => toElement.rubrique.code == element.rubrique!.code,
              orElse: () => RubriqueOnBulletinModel(
                  rubrique: element.rubrique!, value: 0),
            );
            return match.value;
          } else if (element.type == BaseType.valeur) {
            return element.valeur ?? 0;
          } else {
            return 0;
          }
        }).toList();

        if (valeurs.isEmpty) return 0;

        double result = valeurs.fold(0, (a, b) => a + (b ?? 0));
        return result;

      case NatureRubrique.bareme:
        Bareme bareme = rubriqueOnBulletin.rubrique.bareme!;

        final reference = toutesLesRubriquesSurBulletin.firstWhere(
          (el) => el.rubrique.code == bareme.reference.code,
          orElse: () => RubriqueOnBulletinModel(
            rubrique: RubriqueBulletin(
              id: "id",
              rubrique: "rubrique",
              code: "code",
              type: TypeRubrique.gain,
              nature: NatureRubrique.constant,
              portee: null,
            ),
            value: 0,
          ),
        );
        final referenceValue = rubriqueOnBulletin.rubrique.rubriqueIdentity ==
                RubriqueIdentity.anciennete
            ? calculerAncienneteEnAnnees(reference.value!.toInt())
            : reference.value!;
        final Tranche tranche = bareme.tranches.firstWhere(
          (tr) {
            return referenceValue >= tr.min &&
                (tr.max == null || referenceValue <= tr.max!);
          },
          orElse: () => Tranche(
            min: 0,
            max: 0,
            value: TrancheValue(
              type: TrancheValueType.valeur,
              valeur: 0,
            ),
          ),
        );
        if (tranche.value.type == TrancheValueType.valeur) {
          return tranche.value.valeur!;
        } else if (tranche.value.type == TrancheValueType.taux) {
          final double taux = tranche.value.taux!.taux;

          final baseRubrique = toutesLesRubriquesSurBulletin.firstWhere(
            (el) => el.rubrique.code == tranche.value.taux!.base.code,
            orElse: () => RubriqueOnBulletinModel(
              rubrique: rubrique.taux!.base,
              value: 0,
            ),
          );
          final double base = baseRubrique.value ?? 0;
          return taux * base / 100;
        }
        return 0;
    }
  }

  // Helper method to calculate seniority in years (you'll need to implement this)
  static int calculerAncienneteEnAnnees(int value) {
    // Implement the logic to convert the value to years
    // This is a placeholder and should be replaced with actual logic
    return value ~/ 12; // Assuming value is in months
  }
}

// Example usage

//calculer l'ancienneté de d'un personnel
int calculerAncienneteEnMs(
    {required DateTime dateDebutContrat, required int periodeEssai}) {
  DateTime dateFinPeriodeEssai = dateDebutContrat.add(
    Duration(milliseconds: periodeEssai),
  );

  DateTime now = DateTime.now();
  DateTime maintenant = DateTime(now.year, now.month, now.day);

  if (maintenant.isBefore(dateFinPeriodeEssai)) return 0;

  Duration difference = maintenant.difference(dateFinPeriodeEssai);
  return difference.inMilliseconds;
}

double calculerAncienneteEnAnnees(int ancienneteEnMs) {
  const double msParAnnee = 365.25 * 24 * 60 * 60 * 1000;
  return ancienneteEnMs / msParAnnee;
}

// Fonction helper pour formater l'ancienneté
String formatAnciennete(double? valueInMs) {
  if (valueInMs == null) return "0 an";

  final ancienneteEnAnnees = calculerAncienneteEnAnnees(valueInMs.toInt());
  final ancienneteEntiere = ancienneteEnAnnees.floor();

  if (ancienneteEntiere == 0) {
    return "< 1 an";
  } else if (ancienneteEntiere == 1) {
    return "1 an";
  } else {
    return "$ancienneteEntiere ans";
  }
}

// Caluculer le montant de chaque rubrique.
double calculerMontantRubrique({
  required RubriqueOnBulletinModel rubriqueOnBulletin,
  required List<RubriqueOnBulletinModel> toutesLesRubriquesSurBulletin,
}) {
  RubriqueBulletin rubrique = rubriqueOnBulletin.rubrique;
  switch (rubrique.nature) {
    case NatureRubrique.constant:
      return rubriqueOnBulletin.value ?? 0;

    case NatureRubrique.taux:
      final double taux = rubrique.taux!.taux;

      final baseRubrique = toutesLesRubriquesSurBulletin.firstWhere(
        (el) => el.rubrique.code == rubrique.taux!.base.code,
        orElse: () => RubriqueOnBulletinModel(
          rubrique: rubrique.taux!.base,
          value: 0,
        ),
      );

      final double base = baseRubrique.value ?? 0;
      return taux * base / 100;

    case NatureRubrique.calcul:
      final op = rubrique.calcul!.operateur;
      final rubriquesCible = rubrique.calcul!.elements;
      final valeurs = rubriquesCible.map((element) {
        if (element.type == BaseType.rubrique) {
          final r = toutesLesRubriquesSurBulletin.firstWhere(
            (toElement) => toElement.rubrique.code == element.rubrique!.code,
            orElse: () =>
                RubriqueOnBulletinModel(rubrique: element.rubrique!, value: 0),
          );
          return r.value;
        } else if (element.type == BaseType.valeur) {
          return element.valeur;
        }
      }).toList();

      if (valeurs.isEmpty) return 0;

      double result = valeurs[0]!;
      switch (op) {
        case Operateur.addition:
          result += valeurs[1]!;
          break;
        case Operateur.soustraction:
          result -= valeurs[1]!;
          break;
        case Operateur.multiplication:
          result *= valeurs[1]!;
          break;
        case Operateur.division:
          result /= valeurs[1] == 0 ? 1 : valeurs[1]!;
          break;
      }

      return result;

    case NatureRubrique.sommeRubrique:
      final rubriquesCible = rubrique.sommeRubrique!.elements;
      List valeurs = rubriquesCible.map((element) {
        if (element.type == BaseType.rubrique) {
          final match = toutesLesRubriquesSurBulletin.firstWhere(
            (toElement) => toElement.rubrique.code == element.rubrique!.code,
            orElse: () =>
                RubriqueOnBulletinModel(rubrique: element.rubrique!, value: 0),
          );
          return match.value;
        } else if (element.type == BaseType.valeur) {
          return element.valeur ?? 0;
        } else {
          return 0;
        }
      }).toList();

      if (valeurs.isEmpty) return 0;

      double result = valeurs.fold(0, (a, b) => a + (b ?? 0));
      return result;

    case NatureRubrique.bareme:
      Bareme bareme = rubriqueOnBulletin.rubrique.bareme!;

      final reference = toutesLesRubriquesSurBulletin.firstWhere(
          (el) => el.rubrique.code == bareme.reference.code,
          orElse: () => RubriqueOnBulletinModel(
                rubrique: RubriqueBulletin(
                  id: "id",
                  rubrique: "rubrique",
                  code: "code",
                  type: TypeRubrique.gain,
                  nature: NatureRubrique.constant,
                  portee: null,
                ),
                value: 0,
              ));
      final referenceValue = rubriqueOnBulletin.rubrique.rubriqueIdentity ==
              RubriqueIdentity.anciennete
          ? calculerAncienneteEnAnnees(reference.value!.toInt())
          : reference.value!;
      final Tranche tranche = bareme.tranches.firstWhere(
        (tr) {
          return referenceValue >= tr.min &&
              (tr.max == null || referenceValue <= tr.max!);
        },
        orElse: () => Tranche(
          min: 0,
          max: 0,
          value: TrancheValue(
            type: TrancheValueType.valeur,
            valeur: 0,
          ),
        ),
      );
      if (tranche.value.type == TrancheValueType.valeur) {
        return tranche.value.valeur!;
      } else if (tranche.value.type == TrancheValueType.taux) {
        final double taux = tranche.value.taux!.taux;

        final baseRubrique = toutesLesRubriquesSurBulletin.firstWhere(
          (el) => el.rubrique.code == tranche.value.taux!.base.code,
          orElse: () => RubriqueOnBulletinModel(
            rubrique: rubrique.taux!.base,
            value: 0,
          ),
        );
        final double base = baseRubrique.value ?? 0;
        return taux * base / 100;
      }
      return 0;
  }
}

double getFormuleValue({
  required RubriqueBulletin rubrique,
  required List<RubriqueOnBulletinModel> toutesLesRubriquesSurBulletin,
}) {
  final element = toutesLesRubriquesSurBulletin.firstWhere(
    (toElement) => toElement.rubrique.id == rubrique.id,
    orElse: () => RubriqueOnBulletinModel(rubrique: rubrique, value: 0),
  );

  return element.value ?? 0;
}
