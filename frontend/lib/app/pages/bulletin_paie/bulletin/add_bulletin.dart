import 'package:flutter/material.dart';
import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/model/bulletin_paie/bulletin_model.dart';
import 'package:frontend/model/bulletin_paie/salarie_model.dart';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';
import 'package:frontend/model/bulletin_paie/type_rubrique.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/model/request_response.dart';
import 'package:frontend/service/bulletin_service.dart';
import 'package:frontend/widget/simple_text_field.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../helper/amout_formatter.dart';
import '../../../../helper/date_helper.dart';
import '../../../../helper/get_bulletin_period.dart';
import '../../../../model/bulletin_paie/nature_rubrique.dart';
import '../../../../model/bulletin_paie/rubrique_paie.dart';
import '../../../../model/entreprise/banque.dart';
import '../../../../service/banque_service.dart';
import '../../../../service/moyen_paiement_service.dart';
import '../../../../service/rubrique_categorie_conf_service.dart';
import '../../../../widget/date_text_field.dart';
import '../../../../model/personnel/personnel_model.dart';
import '../../../../service/personnel_service.dart';
import '../../../../widget/future_dropdown_field.dart';
import 'package:gap/gap.dart';

import '../../../../widget/validate_button.dart';

class AddBulletinPage extends StatefulWidget {
  // final Future<void> Function() refresh;
  final SalarieModel salarie;
  final DateTime? debutPeriodePaie;
  final DateTime? finPeriodePaie;
  const AddBulletinPage({
    super.key,
    required this.salarie,
    required this.debutPeriodePaie,
    required this.finPeriodePaie,
    // required this.refresh,
  });

  @override
  State<AddBulletinPage> createState() => _AddBulletinState();
}

class _AddBulletinState extends State<AddBulletinPage> {
  late SimpleFontelicoProgressDialog _dialog;
  PersonnelModel? personnel;

  List<RubriqueOnBulletinModel> _rubriquesOnBulletin = [];
  final TextEditingController dateFieldController = TextEditingController();
  final TextEditingController datedebutFieldController =
      TextEditingController();
  final TextEditingController dateFinFieldController = TextEditingController();
  final TextEditingController referenceFiledContoller = TextEditingController();
  DateTime? dateEdition;
  DateTime? debutPeriode;
  DateTime? finPeriode;
  bool isLoading = true;
  bool hasError = false;
  late BulletinPaieModel? previousBulletin;
  Map<String, TextEditingController> valueControllers = {};
  String? errorMessage;
  @override
  void initState() {
    
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _initRubriques();
    super.initState();
  }

  MoyenPaiementModel? moyenPayement;
  BanqueModel? banque;
  Future<void> _initRubriques() async {
    // try {
    previousBulletin = await BulletinService.getPreviousBulletins(
      salarieId: widget.salarie.id,
    );

    final List<RubriqueOnBulletinModel> rubriquePaieResponse =
        await RubriqueCategorieConfService.getBulletinRubriquesByCategoriePaie(
      categorie: widget.salarie.categoriePaie,
    );

    setState(() {
      moyenPayement = previousBulletin?.moyenPayement;
      banque = previousBulletin?.banque;
      dateEdition = previousBulletin?.dateEdition;
      _rubriquesOnBulletin = rubriquePaieResponse;
      dateEdition = DateTime.now();
      dateFieldController.text =
          getStringDate(time: dateEdition ?? DateTime.now());
      // datedebutFieldController.text =
      //     getStringDate(time: widget.debutPeriodePaie ?? DateTime.now());
      isLoading = false;
      hasError = false;
    });

    for (var rubrique in rubriquePaieResponse) {
      final previousValue = previousBulletin?.rubriques
          .firstWhere(
            (r) => r.rubrique.id == rubrique.rubrique.id,
            orElse: () => RubriqueOnBulletinModel(rubrique: rubrique.rubrique),
          )
          .value;

      final valueToSet = previousValue ?? rubrique.value;
      rubrique.value = valueToSet;
      if (valueToSet != null) {
        valueControllers[rubrique.rubrique.id] =
            TextEditingController(text: valueToSet.toString());
      }
    }
    // } catch (e) {
    //   setState(() {
    //     errorMessage = e.toString();
    //     isLoading = false;
    //     hasError = true;
    //   });
    // }
  }

  Future<List<PersonnelModel>> fetchItems() async {
    return await PersonnelService.getUnarchivedPersonnels();
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return moyenPayement == null
        ? await BanqueService.getAllBanques()
        : (await BanqueService.getAllBanques())
            .where((b) => b.type == moyenPayement!.type)
            .toList();
  }

  Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return banque == null
        ? await MoyenPaiementService.getMoyenPaiements()
        : (await MoyenPaiementService.getMoyenPaiements())
            .where((m) => m.type == banque!.type)
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Text(
          errorMessage ??
              "Une erreur est survenue lors du chargement des rubriques.",
        ),
      );
    }

    return SingleChildScrollView(
      child: Form(
        //key: UniqueKey(),
        child: Column(
          children: [
            FutureCustomDropDownField<MoyenPaiementModel>(
              label: "Moyen de paiement",
              selectedItem: moyenPayement,
              fetchItems: fetchMoyenPaiementItems,
              onChanged: (MoyenPaiementModel? value) {
                // if (value != null) {
                setState(() {
                  moyenPayement = value;
                });
                // }
              },
              canClose: true,
              itemsAsString: (s) => s.libelle,
            ),
            FutureCustomDropDownField<BanqueModel>(
              label: "Compte de payement",
              showSearchBox: true,
              selectedItem: banque,
              fetchItems: fetchBanqueItems,
              onChanged: (BanqueModel? value) {
                // if (value != null) {
                setState(() {
                  banque = value;
                });
                // }
              },
              canClose: true,
              itemsAsString: (s) => s.name,
            ),
            SimpleTextField(
              label:
                  "Référence${moyenPayement != null ? " (${moyenPayement!.libelle})" : ""}",
              textController: referenceFiledContoller,
            ),
            DateField(
              onCompleteDate: (value) {
                setState(() {
                  dateEdition = value!;
                  dateFieldController.text = getStringDate(time: value);
                });
              },
              label: "Date d'édition",
              dateController: dateFieldController,
              lastDate: DateTime.now(),
            ),
            if (widget.debutPeriodePaie == null ||
                widget.finPeriodePaie == null) ...[
              DateField(
                onCompleteDate: (value) {
                  setState(() {
                    debutPeriode = value!;
                    datedebutFieldController.text = getStringDate(time: value);
                  });
                },
                label: "Date du début de la période de paie",
                dateController: datedebutFieldController,
                lastDate: finPeriode ?? DateTime.now(),
              ),
              DateField(
                onCompleteDate: (value) {
                  if (value != null) {
                    setState(() {
                      finPeriode = value;
                      dateFinFieldController.text = getStringDate(time: value);
                    });
                  }
                },
                firstDate: debutPeriode,
                label: "Date de fin de la période de paie",
                dateController: dateFinFieldController,
                lastDate: DateTime.now(),
              ),
            ],
            ..._rubriquesOnBulletin.map((rubrique) {
              final r = rubrique.rubrique;

              if (r.nature == NatureRubrique.constant) {
                // On gère les cas particuliers d'abord
                if (r.rubriqueIdentity == RubriqueIdentity.anciennete) {
                  rubrique.value = calculerAncienneteEnMs(
                    dateDebutContrat: widget.salarie.personnel.dateDebut!,
                    periodeEssai: widget.salarie.personnel.dureeEssai!,
                  ).toDouble();
                  return const SizedBox();
                }

                if (r.rubriqueIdentity ==
                    RubriqueIdentity.nombrePersonneCharge) {
                  rubrique.value =
                      widget.salarie.personnel.nombrePersonneCharge?.toDouble();
                  return const SizedBox(); // On n'affiche rien
                }
                if (r.rubriqueIdentity == RubriqueIdentity.avanceSurSalaire) {
                  return const SizedBox(); // On n'affiche rien
                }

                // Pour les autres rubriques constants individuels
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
                );
              }

              return const SizedBox();
            }),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  libelle: "Editer",
                  onPressed: () async {
                    await _addBulletin();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _addBulletin() async {
    if (dateEdition == null ||
        moyenPayement == null ||
        banque == null ||
        referenceFiledContoller.text.isEmpty) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir tous les champs obligatoires.",
      );
      return;
    }

    final List<RubriqueOnBulletinModel> constantesIndividuellesSansValeur =
        _rubriquesOnBulletin.where((rubriqueOnBulletin) {
      final rubrique = rubriqueOnBulletin.rubrique;
      return rubrique.nature == NatureRubrique.constant &&
          rubrique.rubriqueIdentity != RubriqueIdentity.avanceSurSalaire &&
          rubrique.portee == PorteeRubrique.individuel &&
          rubriqueOnBulletin.value == null;
    }).toList();

    if (constantesIndividuellesSansValeur.isNotEmpty ||
        ((widget.debutPeriodePaie == null || widget.finPeriodePaie == null) &&
            (debutPeriode == null || finPeriode == null))) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir tous les champs obligatoires.",
      );
      return;
    }

    _dialog.show(
      message: 'Edition du bulletin en cours',
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    try {
      RubriqueCalculator.calculateRubriquesWithDependencies(
        _rubriquesOnBulletin,
      );
      RequestResponse response = await BulletinService.createBulletin(
        salarie: widget.salarie,
        dateEdition: dateEdition!,
        moyenPayement: moyenPayement!,
        banque: banque!,
        referencePaie: referenceFiledContoller.text,
        bulletinRubriques: _rubriquesOnBulletin,
        debutPeriodePaie: widget.debutPeriodePaie ?? debutPeriode!,
        finPeriodePaie: widget.finPeriodePaie ?? finPeriode!,
      );
      _dialog.hide();
      if (response.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          customMessage: "Bulletin édité avec succès",
          status: PopupStatus.success,
        );
      } else {
        MutationRequestContextualBehavior.showPopup(
          customMessage: response.message,
          status: response.status,
        );
      }
      // widget.refresh();
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
          customMessage: e.toString(), status: PopupStatus.customError);
    }
  }
}
