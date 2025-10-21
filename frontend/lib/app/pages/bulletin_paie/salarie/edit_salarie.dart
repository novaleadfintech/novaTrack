import 'package:flutter/material.dart';
import 'package:frontend/model/bulletin_paie/categorie_paie.dart';
import 'package:frontend/model/habilitation/user_model.dart';
import 'package:frontend/service/categorie_paie_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/bulletin_paie/rubrique.dart';
import '../../../../model/bulletin_paie/rubrique_paie.dart';
import '../../../../model/bulletin_paie/salarie_model.dart';
import '../../../../model/bulletin_paie/tranche_model.dart';
import '../../../../model/personnel/personnel_model.dart';
import '../../../../model/request_response.dart';
import '../../../../service/personnel_service.dart';
import '../../../../service/rubrique_categorie_conf_service.dart';
import '../../../../service/salarie_service.dart';
import '../../../../widget/duration_field.dart';
import '../../../../widget/enum_selector_radio.dart';
import '../../../../widget/future_dropdown_field.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';

class EditSalariePage extends StatefulWidget {
  final SalarieModel salarie;
  final Future<void> Function() refresh;

  const EditSalariePage({
    super.key,
    required this.salarie,
    required this.refresh,
  });

  @override
  State<EditSalariePage> createState() => _EditSalariePageState();
}

class _EditSalariePageState extends State<EditSalariePage> {
  late SimpleFontelicoProgressDialog _dialog;
  TextEditingController salaireController = TextEditingController();
  final TextEditingController _compterController = TextEditingController();

  PersonnelModel? personnel;
  CategoriePaieModel? categoriePaie;
  String? currentPersonnelId;
  String? periodPaieUnit;
  int? periodPaieCompteur;
  TypePaie? typePaie;
  PaieManner? paieManner;

  RubriqueBulletin? salaireRubrique;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _loadCurrentUser();
    _initializeSelectedValues();
  }

  Future<void> _loadCurrentUser() async {
    UserModel? user = await AuthService().decodeToken();
    setState(() {
      currentPersonnelId = user!.personnel!.id;
    });
  }

  void _initializeSelectedValues() async {
    final fetchedPersonnel = (widget.salarie.personnel);
    final fetchedCategorie = widget.salarie.categoriePaie;

    setState(() {
      personnel = fetchedPersonnel;
      categoriePaie = fetchedCategorie;
      paieManner = widget.salarie.paieManner;
      if (widget.salarie.periodPaie != null) {
        _compterController.text = convertDuration(
          durationMs: widget.salarie.periodPaie!,
        ).compteur.toString();
        periodPaieUnit = convertDuration(
          durationMs: widget.salarie.periodPaie!,
        ).unite;
      } else {
        _compterController.text = '';
        periodPaieUnit = null;
      }
    });
  }

  Future<void> updateSalarieData() async {
    try {
      if (personnel == null || categoriePaie == null) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage:
            "Veuillez sélectionner un personnel et une catégorie de paie.",
      );
    }
    if (personnel!.equalTo(personnel: widget.salarie.personnel) &&
          categoriePaie!.equalTo(categoriePaie: widget.salarie.categoriePaie) &&
          paieManner == widget.salarie.paieManner &&
          _compterController.text ==
              convertDuration(
                durationMs: widget.salarie.periodPaie ?? 0,
              ).compteur.toString() &&
          periodPaieUnit ==
              convertDuration(
                durationMs: widget.salarie.periodPaie ?? 0,
              ).unite) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
          customMessage: "Aucune information n'est modifiée",
      );
        return;
      }

      String? errorMessage;
      if (paieManner == null) {
        errorMessage = "Veuillez sélectionner une modalité de paiement.";
      }
      if (paieManner == PaieManner.finMois
          // ||
          //     paieManner == PaieManner.finPeriod
          ) {
        if (_compterController.text.isEmpty || periodPaieUnit == null) {
          errorMessage = "Veuillez remplir les deux champs de durée de paie.";
        }
        periodPaieCompteur = int.tryParse(_compterController.text);
        if (periodPaieCompteur == null) {
          errorMessage =
              "Le compteur de période de paie doit être un nombre entier.";
        }
      }
      if (errorMessage != null) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.information,
          customMessage: errorMessage,
        );
        return;
    }
    _dialog.show(
      message: '',
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

      RequestResponse result = await SalarieService.updateSalarie(
        key: widget.salarie.id,
        personnelId: personnel?.id,
        categoriePaieId: categoriePaie?.id,
        paieManner: paieManner,
        moyenPaiement:
            null, //TODO: à revoir et à mettre les les deux donnée en palce
        periodPaie: (periodPaieCompteur != null && periodPaieUnit != null)
            ? (periodPaieCompteur! * unitMultipliers[periodPaieUnit]!)
            : null,
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Salarié modifié avec succès",
        );
        await widget.refresh();
      } else {
        _dialog.hide();
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    } catch (err) {
 
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: err.toString(),
      );
    }
  }

  Future<List<CategoriePaieModel>> fetchRoleItems() async {
    return await CategoriePaieService.getPaieCategories();
  }

  Future<List<PersonnelModel>> fetchPersonnelItems() async {
    List<PersonnelModel> personnels =
        await PersonnelService.getUnarchivedPersonnels();

    if (currentPersonnelId != null) {
      personnels.removeWhere((p) => p.id == currentPersonnelId);
    }

    return personnels;
  }

  void onValidate() {
    if (personnel != null && categoriePaie != null) {
      updateSalarieData();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage:
            "Veuillez sélectionner un personnel et une catégorie de paie.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureCustomDropDownField<PersonnelModel>(
            label: "Personnel",
            selectedItem: personnel,
            fetchItems: fetchPersonnelItems,
            onChanged: (PersonnelModel? value) {
              setState(() {
                personnel = value;
              });
            },
            itemsAsString: (p) => "${p.nom} ${p.prenom}",
          ),
          FutureCustomDropDownField<CategoriePaieModel>(
            label: "Catégorie de paie",
            selectedItem: categoriePaie,
            fetchItems: fetchRoleItems,
            onChanged: (CategoriePaieModel? value) {
              setState(() {
                categoriePaie = value;
              });
            },
            itemsAsString: (r) => r.categoriePaie,
          ),
          EnumRadioSelector<PaieManner>(
            title: "Modalité de paiement",
            selectedValue: paieManner,
            values: PaieManner.values,
            getLabel: (value) => value.label,
            onChanged: (value) {
              setState(() {
                paieManner = value;
                if (paieManner != PaieManner.finMois
                    //  &&
                    //     paieManner != PaieManner.finPeriod
                    ) {
                  _compterController.clear();
                  periodPaieUnit = null;
                }
              });
            },
            isRequired: true,
          ),
          if (paieManner == PaieManner.finMois
              // ||
              //     paieManner == PaieManner.finPeriod
              ) ...[
            DurationField(
              controller: _compterController,
              label: "Période de paie",
              onUnityChanged: (value) {
                setState(
                  () {
                    periodPaieUnit = value;
                  },
                );
              },
              unitSelectItem: periodPaieUnit,
              required: true,
            ),
          ],
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ValidateButton(
                onPressed: onValidate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<RubriqueBulletin>> fetchRubriqueItems() async {
    if (categoriePaie == null) {
      throw ("Veuillez choisir la catégorie de paie.");
    }

    final List<RubriqueOnBulletinModel> rubriquePaieResponse =
        await RubriqueCategorieConfService.getBulletinRubriquesByCategoriePaie(
      categorie: categoriePaie!,
    );

    List<RubriqueBulletin> rubriques = [];

    for (final categorie in rubriquePaieResponse) {
      rubriques.add(categorie.rubrique);
    }

    return rubriques;
  }
}
