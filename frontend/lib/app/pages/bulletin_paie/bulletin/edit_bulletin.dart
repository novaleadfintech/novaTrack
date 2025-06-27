import 'package:flutter/material.dart';
 import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/model/bulletin_paie/bulletin_model.dart';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';
import 'package:frontend/model/bulletin_paie/type_rubrique.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/model/request_response.dart';
import 'package:frontend/service/bulletin_service.dart';
import 'package:frontend/widget/affiche_information_on_pop_pop.dart';
import 'package:frontend/widget/simple_text_field.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../helper/date_helper.dart';
import '../../../../helper/get_bulletin_period.dart';
import '../../../../model/bulletin_paie/nature_rubrique.dart';
import '../../../../model/bulletin_paie/rubrique_paie.dart';
import '../../../../model/entreprise/banque.dart';
import '../../../../service/banque_service.dart';
import '../../../../service/moyen_paiement_service.dart';
import '../../../../service/rubrique_categorie_conf_service.dart';
import '../../../../model/personnel/personnel_model.dart';
import '../../../../service/personnel_service.dart';
import '../../../../widget/future_dropdown_field.dart';
import 'package:gap/gap.dart';

import '../../../../widget/validate_button.dart';

class EditBulletinPage extends StatefulWidget {
  final VoidCallback refresh;
  final BulletinPaieModel bulletinPaie;

  const EditBulletinPage({
    super.key,
    required this.bulletinPaie,
    required this.refresh,
  });

  @override
  State<EditBulletinPage> createState() => _AddBulletinState();
}

class _AddBulletinState extends State<EditBulletinPage> {
  late SimpleFontelicoProgressDialog _dialog;
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
  Map<String, TextEditingController> valueControllers = {};
  String? errorMessage;
  String? newReferencePaie;
  MoyenPaiementModel? moyenPayement;
  MoyenPaiementModel? newMoyenPayement;
  BanqueModel? banque;
  BanqueModel? newBanque;
  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _initRubriques();
    _initialiseData();
    super.initState();
  }

  _initialiseData() {
    moyenPayement = widget.bulletinPaie.moyenPayement;
    banque = widget.bulletinPaie.banque;
    referenceFiledContoller.text = widget.bulletinPaie.referencePaie!;
    
  }

  // hasChange() {
  //   if (moyenPayement != widget.bulletinPaie.moyenPayement) {
  //     newMoyenPayement = moyenPayement;
  //   }
  //   if (banque!.equalTo(bank: widget.bulletinPaie.banque!)) {
  //     newBanque = banque;
  //   }
  //   if (referenceFiledContoller.text.trim() !=
  //       widget.bulletinPaie.referencePaie!) {
  //     newReferencePaie = referenceFiledContoller.text.trim();
  //   }
  //   if(newBanque == null && newMoyenPayement==null && newReferencePaie ==null){
  //     MutationRequestContextualBehavior.showPopup(
  //       customMessage: "Au",
  //       status: PopupStatus.success,
  //     );
  //   }
  // }

  Future<void> _initRubriques() async {
    try {
      final List<RubriqueOnBulletinModel> rubriquePaieResponse =
          await RubriqueCategorieConfService
              .getBulletinRubriquesByCategoriePaie(
        categorie: widget.bulletinPaie.salarie.categoriePaie,
      );

      // Fusionner les rubriques récupérées avec celles du bulletin existant
      final Map<String, double?> existingRubriques = {
        for (var r in widget.bulletinPaie.rubriques) r.rubrique.id: r.value
      };

      // Injecter les valeurs existantes s'il y en a
      for (var rubrique in rubriquePaieResponse) {
        if (existingRubriques.containsKey(rubrique.rubrique.id)) {
          rubrique.value = existingRubriques[rubrique.rubrique.id];
        }
      }

      setState(() {
        _rubriquesOnBulletin = rubriquePaieResponse;
        isLoading = false;
        hasError = false;
      });

      for (var rubrique in rubriquePaieResponse) {
        if (rubrique.value != null) {
          valueControllers[rubrique.rubrique.id] =
              TextEditingController(text: rubrique.value.toString());
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        hasError = true;
      });
    }
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
      child: Column(
        children: [
          ShowInformation(
            content: widget.bulletinPaie.salarie.personnel.toStringify(),
            libelle: "Salarié",
          ),
          ShowInformation(
            content: getStringDate(time: widget.bulletinPaie.dateEdition),
            libelle: "Date d'édition",
          ),
          ShowInformation(
            content:
                "Du ${getStringDate(time: widget.bulletinPaie.debutPeriodePaie)} au ${getStringDate(
              time: widget.bulletinPaie.finPeriodePaie,
            )}",
            libelle: "Période",
          ),
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
          ..._rubriquesOnBulletin.map((rubrique) {
            final r = rubrique.rubrique;

            if (r.nature == NatureRubrique.constant) {
              // On gère les cas particuliers d'abord
              if (r.rubriqueIdentity == RubriqueIdentity.anciennete) {
                rubrique.value =
                    calculerAncienneteEnMs(
                  dateDebutContrat:
                      widget.bulletinPaie.salarie.personnel.dateDebut!,
                  periodeEssai:
                      widget.bulletinPaie.salarie.personnel.dureeEssai!,
                ).toDouble();
                return const SizedBox();
              }

              if (r.rubriqueIdentity == RubriqueIdentity.avanceSurSalaire) {
                return const SizedBox();
              }

              if (r.rubriqueIdentity == RubriqueIdentity.nombrePersonneCharge) {
                rubrique.value = widget
                    .bulletinPaie.salarie.personnel.nombrePersonneCharge
                    ?.toDouble();
                return const SizedBox();
              }

              return SimpleTextField(
                  label: r.rubrique,
                  textController:
                      valueControllers[r.id] ?? TextEditingController(),
                  required: true,
                  onChanged: (value) {
                    final parsed =
                        value.isEmpty ? null : double.tryParse(value);
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
    );
  }

  _addBulletin() async {
    if (moyenPayement == null ||
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

    if (constantesIndividuellesSansValeur.isNotEmpty) {

      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir tous les champs obligatoires.",
      );
      return;
    }
    // hasChange();
    _dialog.show(
      message: 'Edition du bulletin en cours',
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    try {
      RubriqueCalculator.calculateRubriquesWithDependencies(
        _rubriquesOnBulletin,
      );
      RequestResponse response = await BulletinService.updateBulletin(
        moyenPayement: moyenPayement!,
        banque: banque!,
        key: widget.bulletinPaie.id,
        referencePaie: referenceFiledContoller.text,
        bulletinRubriques: _rubriquesOnBulletin,
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
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        customMessage: e.toString(),
        status: PopupStatus.customError,
      );
    }
  }
}
