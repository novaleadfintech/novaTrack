import 'package:flutter/material.dart';
import 'package:frontend/app/pages/error_page.dart';
import 'package:frontend/app/pages/no_data_page.dart';
import 'package:frontend/helper/amout_formatter.dart';
import 'package:frontend/model/bulletin_paie/categorie_bulletin.dart'
    show CategorieBulletinModel;
import 'package:frontend/model/bulletin_paie/nature_rubrique.dart';
import 'package:frontend/model/bulletin_paie/rubrique.dart';
import 'package:frontend/model/bulletin_paie/type_rubrique.dart';
import 'package:frontend/service/rubrique_categorie_bulletin_conf_service.dart';
import 'package:frontend/widget/simple_text_field.dart';
import 'package:frontend/widget/validate_button.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../helper/get_bulletin_period.dart';
import '../../../../model/bulletin_paie/rubrique_paie.dart';
import '../../../../widget/research_bar.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class RubriqueCategorieConfigPage extends StatefulWidget {
  final CategorieBulletinModel categorieBulletin;

  const RubriqueCategorieConfigPage(
      {super.key, required this.categorieBulletin});

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
    _loadCategorieBulletinRubriques();
    _researchController.addListener(_onSearchChanged);

    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> _loadCategorieBulletinRubriques() async {
     setState(() {
      isLoading = true;
    });
    try {
      rubriqueCategories = await RubriqueCategorieConfService
          .getBulletinRubriquesByCategorieBulletinForConfig(
              categorieBulletin: widget.categorieBulletin);

      // Créer une deep copy pour oldRubriqueCategories
      oldRubriqueCategories = rubriqueCategories
          .map((rubrique) => RubriquePaieConfig(
                rubriqueOnBulletin: RubriqueOnBulletinModel(
                  rubrique: rubrique.rubriqueOnBulletin.rubrique,
                  value: rubrique.rubriqueOnBulletin.value,
                ),
                isChecked: rubrique.isChecked,
              ))
          .toList();

      // Initialiser les contrôleurs avec les valeurs existantes
      for (var rubrique in rubriqueCategories) {
        if (rubrique.rubriqueOnBulletin.value != null) {
          valueControllers[rubrique.rubriqueOnBulletin.rubrique.id] =
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
  List<RubriquePaieConfig> filterCategorieBulletinRubrique() {
    return rubriqueCategories.where((categorieBulletin) {
      return categorieBulletin.rubriqueOnBulletin.rubrique.rubrique
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  void _handleValidation() async {
    List<RubriquePaieConfig> updatedRubriques = [];
    List<RubriquePaieConfig> createdRubriques = [];
    List<RubriquePaieConfig> deletedRubriques = [];

    // Étape 1 : Extraire la liste de toutes les rubriques (cochées ou non)
    List<RubriqueOnBulletinModel> allRubriques =
        rubriqueCategories.map((rc) => rc.rubriqueOnBulletin).toList();

    // Étape 2 : Construire la map des dépendances
    final dependencyMap = {
      for (var rubrique in allRubriques)
        rubrique.rubrique.code:
            RubriqueCalculator.findDependencies(rubrique, allRubriques)
    };
    // Étape 3 : Vérifier les dépendances pour chaque rubrique cochée
    for (var rubrique in rubriqueCategories) {
      if (rubrique.isChecked) {
        final code = rubrique.rubriqueOnBulletin.rubrique.code;
        final deps = dependencyMap[code] ?? {};

        List<String> missingDeps = [];

        for (var depCode in deps) {
          final depRubriques = rubriqueCategories.where(
            (r) => r.rubriqueOnBulletin.rubrique.code == depCode,
          );

          for (var depRubrique in depRubriques) {
            if (!depRubrique.isChecked) {
              missingDeps.add(
                  "\"${depRubrique.rubriqueOnBulletin.rubrique.rubrique}\"");
            }
          }
        }

        if (missingDeps.isNotEmpty) {
          MutationRequestContextualBehavior.showPopup(
            status: PopupStatus.information,
            customMessage:
                "La rubrique \"${rubrique.rubriqueOnBulletin.rubrique.rubrique}\" dépend de : ${missingDeps.join(', ')} qui ne sont pas cochées.",
          );
          return;
        }
      }
    }

    // Traitement normal après validation
    for (var newRubrique in rubriqueCategories) {
      RubriquePaieConfig? oldRubrique;
      try {
        oldRubrique = oldRubriqueCategories.firstWhere(
          (rc) =>
              rc.rubriqueOnBulletin.rubrique.id ==
              newRubrique.rubriqueOnBulletin.rubrique.id,
        );
      } catch (_) {}

      if (newRubrique.isChecked) {
        if (oldRubrique == null || !oldRubrique.isChecked) {
          createdRubriques.add(newRubrique);
        } else {
          final oldValue = oldRubrique.rubriqueOnBulletin.value;
          final newValue = newRubrique.rubriqueOnBulletin.value;

          if (oldValue != newValue) {
            updatedRubriques.add(newRubrique);
          }
        }
      } else {
        if (oldRubrique != null && oldRubrique.isChecked) {
          deletedRubriques.add(oldRubrique);
        }
      }
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      for (var rubrique in createdRubriques) {
        await RubriqueCategorieConfService.createCategorieBulletinRubrique(
          rubriqueId: rubrique.rubriqueOnBulletin.rubrique.id,
          categorieBulletinId: widget.categorieBulletin.id,
          value: rubrique.rubriqueOnBulletin.value,
        );
      }

      for (var rubrique in updatedRubriques) {
        await RubriqueCategorieConfService
            .updateCategorieBulletinRubriqueBulletin(
          rubriqueId: rubrique.rubriqueOnBulletin.rubrique.id,
          categorieBulletinId: widget.categorieBulletin.id,
          value: rubrique.rubriqueOnBulletin.value,
        );
      }

      for (var rubrique in deletedRubriques) {
        await RubriqueCategorieConfService
            .deleteCategorieBulletinRubriqueBulletin(
          rubriqueId: rubrique.rubriqueOnBulletin.rubrique.id,
          categorieBulletinId: widget.categorieBulletin.id,
        );
      }

      _dialog.hide();
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Rubriques configurées avec succès",
      );
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.serverError,
        customMessage: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<RubriquePaieConfig> filteredData = filterCategorieBulletinRubrique();
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (hasError) {
      return Center(
        child: ErrorPage(
          message: errMessage ?? "Erreur lors du chargement",
          onPressed: () async {
            _loadCategorieBulletinRubriques();
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
                    _buildValueField(rubrique, rubriqueConfig),
                  const Divider(color: Color.fromARGB(255, 180, 178, 178))
                ],
              );
            },
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: ValidateButton(onPressed: _handleValidation)),
      ],
    );
  }

  Widget _buildValueField(
      RubriqueBulletin rubrique, RubriquePaieConfig rubriqueConfig) {
    // S'assurer que nous avons un contrôleur pour cette rubrique
    if (!valueControllers.containsKey(rubrique.id)) {
      valueControllers[rubrique.id] = TextEditingController(
          text: rubriqueConfig.rubriqueOnBulletin.value?.toString() ?? "");
    }

    if (rubrique.portee != null && rubrique.portee == PorteeRubrique.commun) {
      return SimpleTextField(
        label: "Valeur de la rubrique",
        textController: valueControllers[rubrique.id]!,
        required: false,
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
    // N'oubliez pas de disposer les contrôleurs
    for (var controller in valueControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
