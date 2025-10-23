import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/responsitvity/responsivity.dart';
import 'package:frontend/helper/amout_formatter.dart';
import 'package:frontend/helper/assets/asset_icon.dart';
import 'package:frontend/helper/get_bulletin_period.dart';
import 'package:frontend/model/bulletin_paie/nature_rubrique.dart'
    show NatureRubrique;
import 'package:frontend/model/bulletin_paie/rubrique_paie.dart';
import 'package:frontend/model/bulletin_paie/salarie_model.dart';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';
import 'package:frontend/service/rubrique_categorie_conf_service.dart';
import 'package:frontend/widget/future_dropdown_field.dart';
import 'package:frontend/widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../widget/simple_text_field.dart';

class VariablePaiePage extends StatefulWidget {
  final SalarieModel salarie;

  const VariablePaiePage({
    super.key,
    required this.salarie,
  });

  @override
  State<VariablePaiePage> createState() => _VariablePaiePageState();
}

class _VariablePaiePageState extends State<VariablePaiePage> {
  late SimpleFontelicoProgressDialog _dialog;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  List<RubriqueOnBulletinModel> _rubriquesOnBulletin = [];
  Map<String, TextEditingController> valueControllers = {};

  DateTime? dateEdition;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _initRubriques();
  }

  Future<void> _initRubriques() async {
    try {
      setState(() => isLoading = true);

      // Récupérer toutes les rubriques liées à la catégorie de paie du salarié
      final rubriquePaieResponse = await RubriqueCategorieConfService
          .getBulletinRubriquesByCategoriePaie(
        categorie: widget.salarie.categoriePaie,
      );

      for (var rubrique in rubriquePaieResponse) {
        valueControllers[rubrique.rubrique.id] = TextEditingController();
      }

      setState(() {
        _rubriquesOnBulletin = rubriquePaieResponse;
        dateEdition = DateTime.now();
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Sauvegarde des rubriques variables dans la table temporaire
  Future<void> _saveValeurRubriqueTemporaire() async {
    try {
      final rubriques = _rubriquesOnBulletin
          .where((r) =>
              r.rubrique.nature != NatureRubrique.constant &&
              r.value != null &&
              r.value != 0)
          .toList();

      // await ValeurRubriqueTemporaireService.createOrUpdate(
      //   salarieId: widget.salarie.id,
      //   rubriques: rubriques,
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Variables de paie enregistrées avec succès."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l’enregistrement : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Text("Erreur : $errorMessage"),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._rubriquesOnBulletin.map((rubrique) {
            final r = rubrique.rubrique;

            // Gestion des rubriques constantes
            if (r.nature == NatureRubrique.constant) {
              if (r.rubriqueIdentity == RubriqueIdentity.anciennete) {
                rubrique.value = calculerAncienneteEnMs(
                  dateDebutContrat: widget.salarie.personnel.dateDebut!,
                  periodeEssai: widget.salarie.personnel.dureeEssai!,
                ).toDouble();
                return const SizedBox();
              }

              if (r.rubriqueIdentity == RubriqueIdentity.nombrePersonneCharge) {
                rubrique.value =
                    widget.salarie.personnel.nombrePersonneCharge?.toDouble();
                return const SizedBox();
              }

              // Autres constantes → rien à afficher
              return const SizedBox();
            }

            // Rubriques variables → champ à saisir
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SimpleTextField(
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
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Frais divers",
                      style: DestopAppStyle.fieldTitlesStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                Gap(4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < widget.controllers.length; i++)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Frais divers ${i + 1}",
                                    style: DestopAppStyle.normalText.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeField(i),
                                    icon: SvgPicture.asset(
                                      AssetsIcons.block,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 0.5,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    Responsive.isMobile(context)
                                        ? Column(
                                            children: [
                                               SimpleTextField(
                                                label: "Libellé",
                                                textController: widget
                                                    .controllers[i]['libelle']!,
                                                required: true,
                                              ),
                                              SimpleTextField(
                                                label: "Montant",
                                                textController: widget
                                                    .controllers[i]['montant']!,
                                                keyboardType:
                                                    TextInputType.number,
                                                required: true,
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Expanded(
                                                child: SimpleTextField(
                                                  label: "Libellé",
                                                  textController:
                                                      widget.controllers[i]
                                                          ['libelle']!,
                                                  required: false,
                                                ),
                                              ),
                                              Expanded(
                                                child: SimpleTextField(
                                                  label: "Montant",
                                                  textController:
                                                      widget.controllers[i]
                                                          ['montant']!,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  required: false,
                                                ),
                                              ),
                                            ],
                                          ),
                                    const Gap(4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Appliquer TVA",
                                            style: DestopAppStyle.normalText
                                                .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                          ),
                                        ),
                                        Switch(
                                          value: widget.controllers[i]['tva'],
                                          onChanged: (bool value) {
                                            setState(() {
                                              widget.controllers[i]['tva'] =
                                                  value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _addField,
                            icon: SvgPicture.asset(
                              AssetsIcons.simpleAdd,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Gap(16),
          Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              libelle: "Enregistrer",
              onPressed: _saveValeurRubriqueTemporaire,
            ),
          ),
        ],
      ),
    );
  }
}
