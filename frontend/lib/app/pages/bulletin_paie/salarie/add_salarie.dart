import 'package:flutter/material.dart';
import '../../../../model/bulletin_paie/categorie_paie.dart';
import '../../../../model/bulletin_paie/nature_rubrique.dart';
import '../../../../model/bulletin_paie/rubrique.dart';
import '../../../../model/bulletin_paie/rubrique_paie.dart';
import '../../../../model/habilitation/user_model.dart';
import '../../../../service/categorie_paie_service.dart';
import '../../../../service/rubrique_categorie_conf_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/bulletin_paie/tranche_model.dart';
import '../../../../model/personnel/personnel_model.dart';
import '../../../../service/personnel_service.dart';
import '../../../../service/salarie_service.dart';
import '../../../../widget/duration_field.dart';
import '../../../../widget/enum_selector_radio.dart';
import '../../../../widget/future_dropdown_field.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';

class AddSalariePage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddSalariePage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddSalariePage> createState() => _AddSalariePageState();
}

class _AddSalariePageState extends State<AddSalariePage> {
  late SimpleFontelicoProgressDialog _dialog;
  final TextEditingController _compterController = TextEditingController();

  PersonnelModel? personnel;
  CategoriePaieModel? categoriePaie;
  String? currentPersonnelId;
  String? periodPaieUnit;
  int? periodPaieCompteur;
  PaieManner? paieManner;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    UserModel? user = await AuthService().decodeToken();
    setState(() {
      currentPersonnelId = user!.personnel!.id;
    });
  }

  Future<void> createSalarie({
    required PersonnelModel personnel,
    required CategoriePaieModel categoriePaie,
  }) async {
    try {
      String? errorMessage;
      if (paieManner == null) {
        errorMessage = "Veuillez sélectionner une modalité de paiement.";
      }
      if (paieManner == PaieManner.finMois ||
          paieManner == PaieManner.finPeriod) {
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

      final result = await SalarieService.createSalarie(
        personnelId: personnel.id,
        categoriePaieId: categoriePaie.id!,
        periodPaie: (periodPaieCompteur != null && periodPaieUnit != null)
            ? (periodPaieCompteur! * unitMultipliers[periodPaieUnit]!)
            : null,
        paieManner: paieManner!,
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Salarié ajouté avec succès",
        );
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.serverError,
        customMessage: e.toString(),
      );
    }
  }

  Future<List<CategoriePaieModel>> _fetchCategoriePaieItems() async {
    return await CategoriePaieService.getPaieCategories();
  }

  Future<List<PersonnelModel>> fetchPersonnelItems() async {
    List<PersonnelModel> personnels =
        await PersonnelService.getUnarchivedPersonnels();

    // // Exclure l'utilisateur connecté de la liste
    // if (currentPersonnelId != null) {
    //   personnels.removeWhere((p) => p.id == currentPersonnelId);
    // }

    return personnels;
  }

  onvalidate() {
    if (personnel != null && categoriePaie != null) {
      createSalarie(
        personnel: personnel!,
        categoriePaie: categoriePaie!,
      );
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
            label: "Categorie de paie",
            selectedItem: categoriePaie,
            fetchItems: _fetchCategoriePaieItems,
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
                if (paieManner != PaieManner.finMois &&
                    paieManner != PaieManner.finPeriod) {
                  _compterController.clear();
                  periodPaieUnit = null;
                }
              });
            },
            isRequired: true,
          ),
          if (paieManner == PaieManner.finMois ||
              paieManner == PaieManner.finPeriod) ...[
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
              required: false,
            ),
          ],
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ValidateButton(
                onPressed: () {
                  onvalidate();
                },
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

    return rubriquePaieResponse
        .where(
          (cat) => cat.rubrique.nature == NatureRubrique.constant,
        )
        .map((cat) => cat.rubrique)
        .toList();
  }
}
