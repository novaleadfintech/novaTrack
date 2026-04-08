import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/error_page.dart';
import 'package:frontend/app/pages/no_data_page.dart';
import 'package:frontend/helper/amout_formatter.dart';
import 'package:frontend/model/bulletin_paie/bulletin_categorie_model.dart';
import 'package:frontend/model/bulletin_paie/nature_rubrique.dart';
import 'package:frontend/model/bulletin_paie/rubrique.dart';
import 'package:frontend/model/bulletin_paie/rubrique_dependance.dart';
import 'package:frontend/model/bulletin_paie/rubrique_on_bulletin_model.dart';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';
import 'package:frontend/model/bulletin_paie/type_rubrique.dart';
import 'package:frontend/service/rubrique_categorie_bulletin_conf_service.dart';
import 'package:frontend/widget/affiche_information_on_pop_pop.dart';
import 'package:frontend/widget/simple_text_field.dart';
import 'package:frontend/widget/validate_button.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../helper/get_bulletin_period.dart';
import '../../../../widget/research_bar.dart';
import '../../../model/request_response.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class RubriqueCategorieConfigPage extends StatefulWidget {
  final BulletinCategorieModel bulletinCategorie;

  const RubriqueCategorieConfigPage(
      {super.key, required this.bulletinCategorie});

  @override
  State<RubriqueCategorieConfigPage> createState() =>
      _RubriqueCategorieConfigPageState();
}

class _RubriqueCategorieConfigPageState
    extends State<RubriqueCategorieConfigPage> {
  bool isLoading = true;
  bool hasError = false;
  String? errMessage;
  List<RubriquePaieConfig> rubriqueCategories = [];
  List<RubriquePaieConfig> oldRubriqueCategories = [];
  Map<String, TextEditingController> valueControllers = {};
  late SimpleFontelicoProgressDialog _dialog;
  final TextEditingController _researchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBulletinCategorieRubriques();
    _researchController.addListener(_onSearchChanged);

    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> _loadBulletinCategorieRubriques() async {
    setState(() {
      isLoading = true;
    });
    try {
      rubriqueCategories = await RubriqueCategorieConfService
          .getBulletinRubriquesByBulletinCategorieForConfig(
              bulletinCategorie: widget.bulletinCategorie);

      // Créer une deep copy pour oldRubriqueCategories
      oldRubriqueCategories = rubriqueCategories
          .map((rubriqueCategorie) => RubriquePaieConfig(
                rubriqueOnBulletin: RubriqueOnBulletinModel(
                  rubrique: rubriqueCategorie.rubriqueOnBulletin.rubrique,
                  value: rubriqueCategorie.rubriqueOnBulletin.value,
                ),
                isChecked: rubriqueCategorie.isChecked,
              ))
          .toList();

      // Initialiser les contrôleurs avec les valeurs existantes
      for (var rubrique in rubriqueCategories) {
        if (rubrique.rubriqueOnBulletin.value != null) {
          valueControllers[rubrique.rubriqueOnBulletin.rubrique.key] =
              TextEditingController(
                  text: rubrique.rubriqueOnBulletin.value?.toString() ?? "");
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errMessage = error.toString();
        hasError = true;
        isLoading = false;
      });
    }
  }

  String searchQuery = "";
  List<RubriquePaieConfig> filterBulletinCategorieRubrique() {
    return rubriqueCategories.where((bulletinCategorie) {
      return bulletinCategorie.rubriqueOnBulletin.rubrique.rubrique
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

// Verication des champs non rempli - retourne true si valide, false sinon
  bool _verifyfieldValue({
    required List<RubriquePaieConfig> rubriqueConfigured,
  }) {
    if (!rubriqueConfigured.any((r) => r.isChecked)) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage:
            'Veuillez configurer les rubrique pour cette catégorie de bulletin.',
      );
      return false;
    }

    for (RubriquePaieConfig rubriqueConf in rubriqueConfigured) {
      if (!rubriqueConf.isChecked) continue;

      final rubrique = rubriqueConf.rubriqueOnBulletin.rubrique;

      if (rubrique.nature != NatureRubrique.constant ||
          rubrique.rubriqueIdentity == RubriqueIdentity.anciennete ||
          rubrique.rubriqueIdentity == RubriqueIdentity.nombrePersonneCharge) {
        continue;
      }

      final controller = valueControllers[rubrique.key];

      if (controller != null && controller.text.isEmpty) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.customError,
          customMessage: 'Veuillez remplir le champs des rubriques marquées *',
        );
        return false;
      }
    }

    return true;
  }

  List<RubriqueDependance> _dependanceShowing({
    required List<RubriquePaieConfig> rubriquesConfigured,
  }) {
    List<RubriqueDependance> result = [];

    final allRubriques =
        rubriquesConfigured.map((e) => e.rubriqueOnBulletin).toList();

    for (var rubriqueConf in rubriquesConfigured) {
      if (!rubriqueConf.isChecked) continue;

      final parent = rubriqueConf.rubriqueOnBulletin.rubrique;

      final deps = RubriqueCalculator.findDependencies(
        rubriqueConf.rubriqueOnBulletin,
        allRubriques,
      );
// .where((r) =>
//   deps.contains(r.rubrique.code) &&
//   !rubriquesConfigured.any((rc) =>
//       rc.rubriqueOnBulletin.rubrique.key == r.rubrique.key &&
//       rc.isChecked))
// dependencedRubriques.addAll(
//         allRubriques
//             .where((r) =>
//                 deps.contains(r.rubrique.code) &&
//                 !rubriquesConfigured.any((rc) =>
//                     rc.rubriqueOnBulletin.rubrique.key == r.rubrique.key &&
//                     rc.isChecked))
//             .map((r) => r.rubrique),
//       );
      for (var r in allRubriques) {
        final alreadyChecked = rubriquesConfigured.any((rc) =>
            rc.rubriqueOnBulletin.rubrique.key == r.rubrique.key &&
            rc.isChecked);

        if (deps.contains(r.rubrique.code) && !alreadyChecked) {
          result.add(
            RubriqueDependance(
              rubrique: r.rubrique,
              parent: parent,
            ),
          );
        }
      }
    }

    return result;
  }

  void _manageDependancesMissing({
    required List<RubriqueDependance> dependencedRubriques,
    required Map<String, bool> selectedDeps,
    required List<RubriquePaieConfig> rubriqueConfigured,
    // required VoidCallback onConfirmed,
  }) {
    // Grouper les dépendances par parent
    final Map<String, List<RubriqueDependance>> depsByParent = {};
    final Map<String, RubriqueBulletin> parents = {};

    for (var dep in dependencedRubriques) {
      depsByParent.putIfAbsent(dep.parent.key, () => []).add(dep);
      parents[dep.parent.key] = dep.parent;
    }

    // État des parents (tous cochés par défaut, sauf sommeRubrique)
    final Map<String, bool> selectedParents = {
      for (var entry in parents.entries)
        if (entry.value.nature != NatureRubrique.sommeRubrique) entry.key: true
    };

    showResponsiveDialog(
      context,
      title: 'Dépendances manquantes',
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShowInstruction(
                  message:
                      'Les rubriques suivantes sont nécessaires pour le calcul. Décochez celles que vous ne souhaitez pas inclure.',
                ),
                const SizedBox(height: 16),

                // Afficher par groupe : parent + ses enfants
                ...depsByParent.entries.map((entry) {
                  final parentKey = entry.key;
                  final parent = parents[parentKey]!;
                  final children = entry.value;
                  final isParentSomme =
                      parent.nature == NatureRubrique.sommeRubrique;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Afficher le parent (sauf si c'est une sommeRubrique)
                      if (!isParentSomme)
                        CheckboxListTile(
                          title: Text(
                            parent.rubrique,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              const Text("Parent - Décocher pour retirer"),
                          value: selectedParents[parentKey],
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedParents[parentKey] = value ?? false;
                              // Si on décoche le parent, décocher ses enfants
                              if (!(value ?? false)) {
                                for (var dep in children) {
                                  selectedDeps[dep.rubrique.key] = false;
                                  _removeRubriqueFromParentFormula(dep: dep);
                                }
                              }
                            });
                          },
                        ),

                      // Titre pour sommeRubrique
                      if (isParentSomme)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 8),
                          child: Text(
                            parent.rubrique,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                      // Afficher les enfants (indentés)
                      ...children.map((dep) {
                        final isParentChecked =
                            selectedParents[parentKey] ?? true;
                        final isEditable = isParentSomme || !isParentChecked;

                        return Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: CheckboxListTile(
                            title: Text(dep.rubrique.rubrique),
                            value: selectedDeps[dep.rubrique.key],
                            onChanged: isEditable
                                ? (value) {
                                    setStateDialog(() {
                                      selectedDeps[dep.rubrique.key] =
                                          value ?? false;
                                    });
                                  }
                                : null,
                          ),
                        );
                      }),

                      const Divider(),
                    ],
                  );
                }),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Décocher les parents non sélectionnés
                        for (var entry in selectedParents.entries) {
                          if (!entry.value) {
                            final parentConfig = rubriqueCategories.firstWhere(
                              (rc) =>
                                  rc.rubriqueOnBulletin.rubrique.key ==
                                  entry.key,
                              orElse: () =>
                                  throw Exception('Parent non trouvé'),
                            );
                            parentConfig.isChecked = false;
                          }
                        }

                        // Appliquer les choix pour les dépendances
                        for (RubriqueDependance dep in dependencedRubriques) {
                          final isChecked =
                              selectedDeps[dep.rubrique.key] ?? false;

                          final rubrique = rubriqueCategories.firstWhere(
                            (rc) =>
                                rc.rubriqueOnBulletin.rubrique.key ==
                                dep.rubrique.key,
                            orElse: () =>
                                throw Exception('Rubrique non trouvée'),
                          );

                          rubrique.isChecked = isChecked;

                          if (!isChecked) {
                            _removeRubriqueFromParentFormula(dep: dep);
                          }
                        }

                        setState(() {});
                        Navigator.pop(context);
                        return;

                        // Exécuter le callback après fermeture du dialog
                        // onConfirmed();
                      },
                      child: const Text('Confirmer'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleValidation({
    required List<RubriquePaieConfig> rubriqueConfigured,
  }) async {
    /// 1. Vérification des champs - arrêter si invalide
    if (!_verifyfieldValue(rubriqueConfigured: rubriqueConfigured)) {
      return;
    }

    /// 2. Récupérer les dépendances
    List<RubriqueDependance> dependencedRubriques =
        _dependanceShowing(rubriquesConfigured: rubriqueConfigured);

    /// 3. Supprimer les doublons
    dependencedRubriques = dependencedRubriques.toSet().toList();

    /// 4. Si pas de dépendances, sauvegarder directement
    if (dependencedRubriques.isEmpty) {
      _performSave(rubriqueConfigured: rubriqueConfigured);
      return;
    }

    /// 5. Gestion des checkbox dynamiques (état local)
    final Map<String, bool> selectedDeps = {
      for (var dep in dependencedRubriques) dep.rubrique.key: true
    };

    /// 6. Afficher le dialog des dépendances et attendre la confirmation
    _manageDependancesMissing(
      dependencedRubriques: dependencedRubriques,
      rubriqueConfigured: rubriqueConfigured,
      selectedDeps: selectedDeps,
    );

  }

  /// Effectue la sauvegarde avec loading
  Future<void> _performSave({
    required List<RubriquePaieConfig> rubriqueConfigured,
  }) async {
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      RequestResponse result =
          await RubriqueCategorieConfService.saveRubriqueCategorieConfig(
              bulletinCategorieKey: widget.bulletinCategorie.key,
              rubriques: rubriqueConfigured
                  .where((r) => r.isChecked)
                  .map((r) => r.rubriqueOnBulletin)
                  .toList());
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Configuration éffectuée avec succès",
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

  /// Supprime une rubrique décochée de la formule de son parent
  void _removeRubriqueFromParentFormula({
    required RubriqueDependance dep,
  }) {
    // Trouver le parent dans rubriqueCategories (la variable d'état principale)
    final parentConfig = rubriqueCategories.firstWhere(
      (rc) => rc.rubriqueOnBulletin.rubrique.key == dep.parent.key,
      orElse: () => throw Exception('Parent non trouvé'),
    );

    final parentRubrique = parentConfig.rubriqueOnBulletin.rubrique;
    final rubriqueCodeToRemove = dep.rubrique.code;

    // Modifier le calcul si c'est un calcul
    // if (parentRubrique.nature == NatureRubrique.calcul &&
    //     parentRubrique.calcul != null) {
    //   final newElements = parentRubrique.calcul!.elements.where((element) {
    //     if (element.type == BaseType.rubrique && element.rubrique != null) {
    //       return element.rubrique!.code != rubriqueCodeToRemove;
    //     }
    //     return true;
    //   }).toList();

    //   if (newElements.length != parentRubrique.calcul!.elements.length) {
    //     parentConfig.rubriqueOnBulletin.rubrique.setCalcul(
    //       newCalcul: Calcul(
    //         operateur: parentRubrique.calcul!.operateur,
    //         elements: newElements,
    //       ),
    //     );
    //   }
    // }

    // Modifier la sommeRubrique si c'est une somme
    if (parentRubrique.nature == NatureRubrique.sommeRubrique &&
        parentRubrique.sommeRubrique != null) {
      final newElements =
          parentRubrique.sommeRubrique!.elements.where((element) {
        if (element.type == BaseType.rubrique && element.calculRubrique != null) {
          return element.calculRubrique!.code != rubriqueCodeToRemove;
        }
        return true;
      }).toList();

      if (newElements.isNotEmpty &&
          newElements.length != parentRubrique.sommeRubrique!.elements.length) {
        parentConfig.rubriqueOnBulletin.rubrique.setSommeRubrique(
          newSommeRubrique: Calcul(
            operateur: parentRubrique.sommeRubrique!.operateur,
            elements: newElements,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<RubriquePaieConfig> filteredData = filterBulletinCategorieRubrique();
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (hasError) {
      return Center(
        child: ErrorPage(
          message: errMessage ?? "Erreur lors du chargement",
          onPressed: () async {
            _loadBulletinCategorieRubriques();
          },
        ),
      );
    }
    if (filteredData.isEmpty) {
      return NoDataPage(
        data: filteredData,
        message: "Aucune rubrique n'est enregistré",
      );
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResearchBar(
              hintText: "Rechercher par rubrique",
              controller: _researchController,
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              RubriquePaieConfig rubriqueConfig = filteredData[index];
              final rubrique = rubriqueConfig.rubriqueOnBulletin.rubrique;
              final isChecked = rubriqueConfig.isChecked;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(rubrique.rubrique),
                    trailing: Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          rubriqueConfig.isChecked = value ?? false;
                        });
                      },
                    ),
                  ),
                  if (isChecked && rubrique.nature == NatureRubrique.constant)
                    _buildValueField(
                      currentRubrique: rubrique,
                      rubriqueConfig: rubriqueConfig,
                    ),
                  const Divider(color: Color.fromARGB(255, 180, 178, 178))
                ],
              );
            },
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: ValidateButton(onPressed: () {
              _handleValidation(rubriqueConfigured: rubriqueCategories);
            })),
      ],
    );
  }

  Widget _buildValueField(
      {required RubriqueBulletin currentRubrique,
      required RubriquePaieConfig rubriqueConfig}) {
    if (!valueControllers.containsKey(currentRubrique.key)) {
      valueControllers[currentRubrique.key] = TextEditingController(
          text: rubriqueConfig.rubriqueOnBulletin.value?.toString() ?? "");
    }

    if (currentRubrique.portee != null &&
        (currentRubrique.portee == PorteeRubrique.commun ||
            currentRubrique.portee == PorteeRubrique.defaultIndividuel)) {
      return SimpleTextField(
        label: "Valeur de la rubrique",
        textController: valueControllers[currentRubrique.key]!,
        required: true,
        onChanged: (value) {
          final parsed = value.isEmpty
              ? null
              : double.tryParse(Formatter.parseAmount(value));
          rubriqueConfig.rubriqueOnBulletin.value = parsed;
        },
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
    }
    return SizedBox();
  }

  @override
  void dispose() {
    for (var controller in valueControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
