import 'package:flutter/material.dart';
import 'package:frontend/model/grille_salariale/categorie_paie.dart';
import 'package:frontend/model/grille_salariale/echelon_model.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/service/banque_service.dart';
import 'package:frontend/service/grille_categorie_paie_service.dart';
import 'package:frontend/widget/drop_down_text_field.dart';
import 'package:frontend/widget/simple_text_field.dart';
import '../../../../model/bulletin_paie/categorie_paie.dart';
import '../../../../model/bulletin_paie/nature_rubrique.dart';
import '../../../../model/bulletin_paie/rubrique.dart';
import '../../../../model/bulletin_paie/rubrique_paie.dart';
import '../../../../model/entreprise/banque.dart';
import '../../../../model/grille_salariale/classe_model.dart' show ClasseModel;
import '../../../../model/habilitation/user_model.dart';
import '../../../../service/categorie_paie_service.dart';
import '../../../../service/moyen_paiement_service.dart';
import '../../../../service/rubrique_categorie_conf_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/bulletin_paie/tranche_model.dart';
import '../../../../model/personnel/personnel_model.dart';
import '../../../../service/personnel_service.dart';
import '../../../../service/salarie_service.dart';
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
  final TextEditingController _numeroDeCompteController =
      TextEditingController();
  final TextEditingController _numeroMatriculeController =
      TextEditingController();

  PersonnelModel? personnel;
  CategoriePaieModel? categoriePaieBulletiin;
  ClasseModel? classe;
  EchelonModel? echelon;
  GrilleCategoriePaieModel? grilleCategoriePaie;
  String? currentPersonnelId;
  String? periodPaieUnit;
  int? periodPaieCompteur;
  PaieManner? paieManner;
  MoyenPaiementModel? moyenPaiement;
  BanqueModel? paiementPlace;

  @override
  void initState() {
    paieManner = PaieManner.finMois;
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _loadCurrentUser();
    super.initState();
  }

  Future<void> _loadCurrentUser() async {
    UserModel? user = await AuthService().decodeToken();
    setState(() {
      currentPersonnelId = user!.personnel!.id;
    });
  }

  Future<void> createSalarie({
    required PersonnelModel personnel,
    required CategoriePaieModel categoriePaieBulletiin,
  }) async {
    try {
      String? errorMessage;
      if (paieManner == null ||
          moyenPaiement == null ||
          paiementPlace == null) {
        errorMessage = "Veuillez renseigner les champs marqués *";
      }

      // if (_numeroMatriculeController.text.isEmpty) {
      //   errorMessage = "Veuillez renseignez le numéro de compte.";
      // }
      // if (paieManner == PaieManner.finMois // ||
      //     // paieManner == PaieManner.finPeriod
      //     ) {
      //   if (_compterController.text.isEmpty || periodPaieUnit == null) {
      //     errorMessage = "Veuillez remplir les deux champs de durée de paie.";
      //   }
      //   periodPaieCompteur = int.tryParse(_compterController.text);
      //   if (periodPaieCompteur == null) {
      //     errorMessage =
      //         "Le compteur de période de paie doit être un nombre entier.";
      //   }
      // }
      if (paieManner == PaieManner.finMois // ||
          // paieManner == PaieManner.finPeriod
          ) {
        periodPaieCompteur = 1;
        periodPaieUnit = "Mois";
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
        categoriePaieId: categoriePaieBulletiin.id!,
        periodPaie: (periodPaieCompteur != null && periodPaieUnit != null)
            ? (periodPaieCompteur! * unitMultipliers[periodPaieUnit]!)
            : null,
        paieManner: paieManner!,
        numeroMatricule: _numeroMatriculeController.text.trim(),
        moyenPaiement: moyenPaiement!,
        numeroCompte: _numeroDeCompteController.text.isNotEmpty
            ? _numeroDeCompteController.text.trim()
            : null,
        paiementPlace: paiementPlace!,
        classe: classe!,
        echelon: echelon!,
        grilleCategoriePaie: grilleCategoriePaie!,
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

  Future<List<GrilleCategoriePaieModel>>
      _fetchGrilleCategoriePaieItems() async {
    return await GrilleCategoriePaieService.getGrilleCategoriePaies();
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
    if (personnel != null && categoriePaieBulletiin != null) {
      createSalarie(
        personnel: personnel!,
        categoriePaieBulletiin: categoriePaieBulletiin!,
      );
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage:
            "Veuillez sélectionner un personnel et une catégorie de paie.",
      );
    }
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return moyenPaiement == null
        ? await BanqueService.getAllBanques()
        : (await BanqueService.getAllBanques())
            .where((b) => b.type == moyenPaiement!.type)
            .toList();
  }

  Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return paiementPlace == null
        ? await MoyenPaiementService.getMoyenPaiements()
        : (await MoyenPaiementService.getMoyenPaiements())
            .where((m) => m.type == paiementPlace!.type)
            .toList();
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
          SimpleTextField(
            label: "Numéro matricule",
            textController: _numeroMatriculeController,
          ),
          FutureCustomDropDownField<CategoriePaieModel>(
            label: "Categorie de bulletin de paie",
            selectedItem: categoriePaieBulletiin,
            fetchItems: _fetchCategoriePaieItems,
            onChanged: (CategoriePaieModel? value) {
              setState(() {
                categoriePaieBulletiin = value;
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
                if (paieManner != PaieManner.finMois //&&
                    // paieManner != PaieManner.finPeriod
                    ) {
                  _compterController.clear();
                  periodPaieUnit = null;
                }
              });
            },
            isRequired: true,
          ),

          FutureCustomDropDownField<MoyenPaiementModel>(
            label: "Moyen de paiement",
            selectedItem: moyenPaiement,
            fetchItems: fetchMoyenPaiementItems,
            onChanged: (MoyenPaiementModel? value) {
              // if (value != null) {
              setState(() {
                moyenPaiement = value;
              });
              // }
            },
            canClose: true,
            itemsAsString: (s) => s.libelle,
          ),
          FutureCustomDropDownField<BanqueModel>(
            label: "Compte de payement",
            showSearchBox: true,
            selectedItem: paiementPlace,
            fetchItems: fetchBanqueItems,
            onChanged: (BanqueModel? value) {
              // if (value != null) {
              setState(() {
                paiementPlace = value;
              });
              // }
            },
            canClose: true,
            itemsAsString: (s) => s.name,
          ),
          SimpleTextField(
            label: "Numéro de compte",
            textController: _numeroDeCompteController,
            required: false,
          ),
          // if (paieManner == PaieManner.finMois
          //     // ||
          //     //     paieManner == PaieManner.finPeriod
          //     ) ...[
          //   DurationField(
          //     controller: _compterController,
          //     label: "Période de paie",
          //     onUnityChanged: (value) {
          //       setState(
          //         () {
          //           periodPaieUnit = value;
          //         },
          //       );
          //     },
          //     unitSelectItem: periodPaieUnit,
          //     required: true,
          //   ),
          // ],
          FutureCustomDropDownField<GrilleCategoriePaieModel>(
            label: "Categorie de paie",
            selectedItem: grilleCategoriePaie,
            fetchItems: _fetchGrilleCategoriePaieItems,
            onChanged: (GrilleCategoriePaieModel? value) {
              setState(() {
                grilleCategoriePaie = value;
              });
            },
            itemsAsString: (r) => r.libelle,
          ),
          if (grilleCategoriePaie != null)
            CustomDropDownField(
              items: grilleCategoriePaie!.classes!,
              onChanged: (value) {
                setState(() {
                  classe = value;
                });
              },
              label: "Classe",
              itemsAsString: (classe) => classe.libelle,
            ),
          if (classe != null)
            CustomDropDownField(
              items: classe!.echelonIndiciciaires!,
              onChanged: (value) {
                echelon = value!.echelon;
              },
              label: "Echelon",
              itemsAsString: (echelon) {
                return echelon.echelon.libelle;
              },
            ),
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
    if (categoriePaieBulletiin == null) {
      throw ("Veuillez choisir la catégorie de paie.");
    }

    final List<RubriqueOnBulletinModel> rubriquePaieResponse =
        await RubriqueCategorieConfService.getBulletinRubriquesByCategoriePaie(
      categorie: categoriePaieBulletiin!,
    );

    return rubriquePaieResponse
        .where(
          (cat) => cat.rubrique.nature == NatureRubrique.constant,
        )
        .map((cat) => cat.rubrique)
        .toList();
  }
}
