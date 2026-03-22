import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/helper/amout_formatter.dart';
import 'package:frontend/helper/assets/asset_icon.dart';
import 'package:frontend/model/bulletin_paie/rubrique.dart';
import 'package:frontend/model/bulletin_paie/rubrique_paie.dart';
import 'package:frontend/model/bulletin_paie/salarie_model.dart';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';
import 'package:frontend/model/bulletin_paie/valeur_rubrique_temporaire.dart';
import 'package:frontend/service/bulletin_rubrique_service.dart';
import 'package:frontend/service/rubrique_categorie_bulletin_conf_service.dart';
import 'package:frontend/service/valeur_rubrique_temporaire_service.dart';
import 'package:frontend/style/app_style.dart';
import 'package:frontend/widget/future_dropdown_field.dart';
import 'package:frontend/widget/simple_text_field.dart';
import 'package:frontend/widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../model/bulletin_paie/nature_rubrique.dart';

class VariablePaiePage extends StatefulWidget {
  final SalarieModel salarie;
  const VariablePaiePage({super.key, required this.salarie});

  @override
  State<VariablePaiePage> createState() => _VariablePaiePageState();
}

class _VariablePaiePageState extends State<VariablePaiePage> {
  List<Map<String, dynamic>> primesExceptionnelles = [];
  Map<String, TextEditingController> valueControllers = {};
  late SimpleFontelicoProgressDialog _dialog;
  List<RubriqueOnBulletinModel> _rubriquesOnBulletin = [];
  List<RubriqueOnBulletinModel> variablePaies = [];
  List<RubriqueOnBulletinModel> variableRubriques = [];
  List<RubriqueOnBulletinModel> nonVariableRubriques = [];
// Liste pour les rubriques non variables

  bool isLoading = true;
  bool hasError = false;
  void _addPrime() {
    setState(() {
      primesExceptionnelles.add({
        "prime": null,
        "montant": TextEditingController(),
      });
    });
  }

  void _removePrime(int index) {
    setState(() {
      primesExceptionnelles.removeAt(index);
    });
  }

  /// Récupération de la liste des primes disponibles depuis le service
  Future<List<RubriqueBulletin>> fetchPrimes() async {
    try {
      final primes = await BulletinRubriqueService.getExceptionnellePrime();
      return primes;
    } catch (e) {
      debugPrint("Erreur lors du chargement des primes: $e");
      return [];
    }
  }

  /// Conversion en texte pour le dropdown
  String itemAsString(RubriqueBulletin p) => p.rubrique;
  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _initRubriques();
    super.initState();
  }

  Future<void> _initRubriques() async {
    try {
      // On attend désormais un ValeurRubriqueTemporaire (contenant rubriques et primesExceptionnelles)
      final ValeurRubriqueTemporaire valeurResponse =
          await RubriqueCategorieConfService
              .getvariablePaieAndPrimeExceptionnelles(
        categorieBulletin: widget.salarie.categorieBulletin,
        salarieId: widget.salarie.id,
      );

      // Si rien reçu, on initialise avec listes vides
      final List<RubriqueOnBulletinModel> rubriquePaieResponse =
          valeurResponse.rubriques;
    
      variablePaies.addAll(valeurResponse.rubriques.where((rubrque) {
        return rubrque.rubrique.rubriqueRole == RubriqueRole.variable;
      }).toList());

      nonVariableRubriques.addAll(valeurResponse.rubriques.where((rubrque) {
        return rubrque.rubrique.rubriqueRole != RubriqueRole.variable;
      }).toList());
      // Préremplir les controllers des rubriques constantes
      for (var rubriqueBulletin in rubriquePaieResponse) {
        final r = rubriqueBulletin.rubrique;
        if (r.nature == NatureRubrique.constant) {
          final controller = TextEditingController();
          if (rubriqueBulletin.value != null) {
            controller.text = rubriqueBulletin.value.toString();
          }
          valueControllers[r.id] = controller;
        }
      }

      // Préremplir la liste primesExceptionnelles UI si elle existe dans la réponse
      primesExceptionnelles = [];
      final primesFromServer = valeurResponse.primesExceptionnelles ?? [];
      for (var primeOnBulletin in primesFromServer) {
        primesExceptionnelles.add({
          "prime": primeOnBulletin.rubrique,
          "montant": TextEditingController(
              text: primeOnBulletin.value != null
                  ? primeOnBulletin.value.toString()
                  : ""),
        });
      }

      setState(() {
        _rubriquesOnBulletin = nonVariableRubriques;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            //key: UniqueKey(),
            child: Column(
              children: [
                ...nonVariableRubriques.map((rubrique) {
                  final r = rubrique.rubrique;
                  if (r.nature == NatureRubrique.constant) {
                    // On gère les cas particuliers d'abord
                    // if (r.rubriqueIdentity == RubriqueIdentity.anciennete) {
                    //   rubrique.value = calculerAncienneteEnMs(
                    //     dateDebutContrat: widget.salarie.personnel.dateDebut!,
                    //     periodeEssai: widget.salarie.personnel.dureeEssai!,
                    //   ).toDouble();
                    //   return const SizedBox();
                    // }

                    // if (r.rubriqueIdentity ==
                    //     RubriqueIdentity.nombrePersonneCharge) {
                    //   rubrique.value = widget
                    //       .salarie.personnel.nombrePersonneCharge
                    //       ?.toDouble();
                    //   return const SizedBox(); // On n'affiche rien
                    // }
                    // if (r.rubriqueIdentity ==
                    //     RubriqueIdentity.avanceSurSalaire) {
                    //   return const SizedBox(); // On n'affiche rien
                    // }

                    return SimpleTextField(
                      label: r.rubrique,
                      textController:
                          valueControllers[r.id] ?? TextEditingController(),
                      required: true,
                      onChanged: (value) {
                        final parsed = value.isEmpty
                            ? null
                            : double.tryParse(Formatter.parseAmount(value));
                        rubrique.value = parsed;
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      // maxlength: 2,
                    );
                    
                  }

                  return const SizedBox();
                }),
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            height: 16,
                          ),
                        ),
                        Gap(8),
                        Text(
                          'Variable de paie',
                          style: DestopAppStyle.fieldTitlesStyle.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        Gap(8),
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            height: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (variablePaies.isEmpty)
                    Text(
                      "Aucune variable de paie à renseigner pour ce salarié.",
                      textAlign: TextAlign.center,
                      style: DestopAppStyle.normalText.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                  ...variablePaies.map((rubrique) {
                    final r = rubrique.rubrique;
                    return SimpleTextField(
                      label: r.rubrique,
                      textController:
                          valueControllers[r.id] ?? TextEditingController(),
                      required: true,
                      onChanged: (value) {
                        final parsed = value.isEmpty
                            ? null
                            : double.tryParse(Formatter.parseAmount(value));
                        rubrique.value = parsed;
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      // maxlength: 2,
                    );
                  }),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Divider(thickness: 2, height: 16)),
                    Gap(8),
                    Text(
                      "Primes Exceptionnelles",
                      style: DestopAppStyle.fieldTitlesStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    Gap(8),
                    Expanded(child: Divider(thickness: 2, height: 16)),
                  ],
                ),
             
                const Gap(8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5, color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < primesExceptionnelles.length; i++)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Prime ${i + 1}",
                                    style: DestopAppStyle.normalText.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removePrime(i),
                                    icon: SvgPicture.asset(AssetsIcons.block),
                                  ),
                                ],
                              ),
                              FutureCustomDropDownField<RubriqueBulletin>(
                                label: "Sélectionnez une prime",
                                selectedItem: primesExceptionnelles[i]["prime"],
                                fetchItems: fetchPrimes,
                                onChanged: (RubriqueBulletin? selected) {
                                  setState(() {
                                    primesExceptionnelles[i]["prime"] =
                                        selected;
                                  });
                                },
                                itemsAsString: itemAsString,
                              ),
                              SimpleTextField(
                                label: "Montant",
                                textController: primesExceptionnelles[i]
                                    ["montant"],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                required: true,
                                onChanged: (value) {
                                  final parsed = value.isEmpty
                                      ? 0
                                      : double.tryParse(
                                              Formatter.parseAmount(value)) ??
                                          0;
                                  primesExceptionnelles[i]["montant"].text =
                                      parsed.toString();
                                },
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _addPrime,
                            icon: SvgPicture.asset(AssetsIcons.simpleAdd),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              libelle: "Enregistrer",
              onPressed: () {
                _addVariablePaie();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addVariablePaie() async {
    List<RubriqueOnBulletinModel> variablesPaie = [];
    List<RubriqueOnBulletinModel> primesPaie = [];
    List<String> erreurs = [];

    for (var rubrique in [...nonVariableRubriques, ...variablePaies]) {
      final nom = rubrique.rubrique.rubrique;
      // On considère que les rubriques normales doivent avoir une value
      if (rubrique.rubrique.nature == NatureRubrique.constant) {
        if (rubrique.value == null) {
          erreurs
              .add("Veuillez renseigner la valeur pour la rubrique \"$nom\".");
        } else {
          variablesPaie.add(
            RubriqueOnBulletinModel(
              rubrique: rubrique.rubrique,
              value: rubrique.value,
            ),
          );
        }
      }
    }

    // 🔹 Vérifie les primes exceptionnelles saisies séparément
    for (int i = 0; i < primesExceptionnelles.length; i++) {
      final rubrique = primesExceptionnelles[i]["prime"];
      final montantController = primesExceptionnelles[i]["montant"];

      if (rubrique == null) {
        erreurs.add("Veuillez sélectionner une prime (Prime ${i + 1}).");
        continue;
      }

      if (montantController == null || montantController.text.isEmpty) {
        erreurs.add("Veuillez renseigner le montant pour la prime ${i + 1}.");
        continue;
      }

      final montant = double.tryParse(montantController.text);
      if (montant == null) {
        erreurs.add("Montant invalide pour la prime ${i + 1}.");
        continue;
      }

      // Empêcher d’ajouter deux fois la même prime dans la liste des primes
      final alreadyExistsPrime = primesPaie.any(
        (r) => r.rubrique.rubrique == rubrique.rubrique,
      );
      if (!alreadyExistsPrime) {
        primesPaie.add(
          RubriqueOnBulletinModel(
            rubrique: rubrique,
            value: montant,
          ),
        );
      }
    }

    if (erreurs.isNotEmpty) {
      final message = erreurs.join("\n");
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: message,
      );
      return;
    }

    setState(() {
      _rubriquesOnBulletin = variablesPaie;
    });

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      _dialog.hide();

      // TODO: adapter le nom de la méthode de service si nécessaire.
      // Exemple d'appel (vérifier l'API du service ValeurRubriqueTemporaireService) :
      var result = await ValariablePaieService.createValariablePaie(
          salarie: widget.salarie,
          primesExceptionnelles: primesPaie.isNotEmpty ? primesPaie : [],
          variablePaie: variablesPaie);

      if (result.status == PopupStatus.success) {
        setState(() {
          primesExceptionnelles.clear();
          for (var rubrique in _rubriquesOnBulletin) {
            rubrique.value = null;
          }
        });

        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Rubriques enregistrées avec succès ✅",
        );
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: e.toString(),
      );
    }
  }
}
