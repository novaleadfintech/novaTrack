import 'package:flutter/material.dart';
import 'package:frontend/model/bulletin_paie/categorie_paie.dart';
import 'package:frontend/model/bulletin_paie/operateur_model.dart';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import 'package:frontend/model/grille_salariale/echelon_indice_model.dart';
import 'package:frontend/model/habilitation/user_model.dart';
import 'package:frontend/service/categorie_paie_service.dart';
import 'package:gap/gap.dart';
import 'package:frontend/model/grille_salariale/categorie_paie.dart';
import 'package:frontend/model/grille_salariale/echelon_model.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/service/grille_categorie_paie_service.dart';
import 'package:frontend/service/moyen_paiement_service.dart';
import 'package:frontend/widget/drop_down_text_field.dart';
import 'package:frontend/widget/simple_text_field.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/bulletin_paie/rubrique.dart';
import '../../../../model/bulletin_paie/rubrique_paie.dart';
import '../../../../model/bulletin_paie/salarie_model.dart';
import '../../../../model/bulletin_paie/tranche_model.dart';
import '../../../../model/personnel/personnel_model.dart';
import '../../../../model/request_response.dart';
import '../../../../service/operateur_service.dart';
import '../../../../service/personnel_service.dart';
import '../../../../service/rubrique_categorie_conf_service.dart';
import '../../../../service/salarie_service.dart';
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

  // Nouveaux champs/contrôleurs ajoutés
  final TextEditingController _numeroDeCompteController =
      TextEditingController();
  final TextEditingController _numeroMatriculeController =
      TextEditingController();
  MoyenPaiementModel? moyenPaiement;
  GrilleCategoriePaieModel? grilleCategoriePaie;
  ClasseModel? classe;
  EchelonModel? echelon;
  EchelonIndiceModel? echelonIndiciciaires;
  OperateurModel? _operateur;

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
    final fetchedPersonnel = widget.salarie.personnel;
    final fetchedCategorie = widget.salarie.categoriePaie;
    final List<GrilleCategoriePaieModel> categorie =
        await GrilleCategoriePaieService.getGrilleCategoriePaies();

    setState(() {
      personnel = fetchedPersonnel;
      categoriePaie = fetchedCategorie;
      paieManner = widget.salarie.paieManner;

      // pré-remplissage période
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

      // pré-remplissage des nouveaux champs
      _numeroDeCompteController.text = widget.salarie.numeroCompte ?? '';
      _numeroMatriculeController.text = widget.salarie.numeroMatricule ?? '';
      moyenPaiement = widget.salarie.moyenPaiement;
      _operateur = widget.salarie.operateur;

      // Trouver la grille complète correspondant à celle du salarié (si présente)
      if (widget.salarie.grilleCategoriePaie != null) {
        final matches = categorie
            .where(
                (grille) => grille.id == widget.salarie.grilleCategoriePaie!.id)
            .toList();
        grilleCategoriePaie = matches.isNotEmpty
            ? matches.first
            : widget.salarie.grilleCategoriePaie;
      } else {
        grilleCategoriePaie = null;
      }

      if (widget.salarie.classe != null) {
        final matches = grilleCategoriePaie!.classes!
            .where((classe) => classe.id == widget.salarie.classe!.id)
            .toList();
        classe = matches.isNotEmpty ? matches.first : widget.salarie.classe;
      } else {
        classe = null;
      }

      if (widget.salarie.echelon != null) {
        final matches = classe!.echelonIndiciciaires!
            .where((echelonIndiciciaire) =>
                echelonIndiciciaire.echelon.id == widget.salarie.echelon!.id)
            .toList();
        echelon =
            matches.isNotEmpty ? matches.first.echelon : widget.salarie.echelon;
      } else {
        echelon = null;
      }

      echelonIndiciciaires = echelon != null
          ? EchelonIndiceModel(echelon: widget.salarie.echelon!, indice: 0)
          : null;
    });
  }

  Future<List<OperateurModel>> fetchOperateurItems() async {
    return await OperateurService.getOperateurs();
  }

  Future<void> updateSalarieData() async {
    try {
      if (personnel == null || categoriePaie == null) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.information,
          customMessage:
              "Veuillez sélectionner un personnel et une catégorie de paie.",
        );
        return;
      }
      // if (personnel!.equalTo(personnel: widget.salarie.personnel) &&
      //     categoriePaie!.equalTo(categoriePaie: widget.salarie.categoriePaie) &&
      //     paieManner == widget.salarie.paieManner &&
      //     _compterController.text ==
      //         convertDuration(
      //           durationMs: widget.salarie.periodPaie ?? 0,
      //         ).compteur.toString() &&
      //     periodPaieUnit ==
      //         convertDuration(
      //           durationMs: widget.salarie.periodPaie ?? 0,
      //         ).unite) {
      //   MutationRequestContextualBehavior.showPopup(
      //     status: PopupStatus.information,
      //     customMessage: "Aucune information n'est modifiée",
      //   );
      //   return;
      // }

      String? errorMessage;
      if (paieManner == null) {
        errorMessage = "Veuillez sélectionner une modalité de paiement.";
      }
      // Validation du moyen de paiement et lieu
      if (moyenPaiement == null) {
        errorMessage = "Veuillez sélectionner un moyen de paiement.";
      }
      if (_operateur == null) {
        errorMessage = "Veuillez renseigner l'opérateur.";
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

      if (paieManner == null ||
          moyenPaiement == null ||
          grilleCategoriePaie == null ||
          classe == null ||
          echelon == null ||
          _operateur == null) {
        errorMessage = "Veuillez renseigner les champs marqués *";
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
        moyenPaiement: moyenPaiement,
        numeroMatricule: _numeroMatriculeController.text.isNotEmpty
            ? _numeroMatriculeController.text.trim()
            : null,
        operateur: _operateur,
        numeroCompte: _numeroDeCompteController.text.isNotEmpty
            ? _numeroDeCompteController.text.trim()
            : null,
        grilleCategoriePaie: grilleCategoriePaie,
        classe: classe,
        echelon: echelon,
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

  Future<List<CategoriePaieModel>> fetchPaieCategorieItems() async {
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

  // Fetchers pour les nouveaux dropdowns
  Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return await MoyenPaiementService.getMoyenPaiements();
  }

  Future<List<GrilleCategoriePaieModel>>
      _fetchGrilleCategoriePaieItems() async {
    return await GrilleCategoriePaieService.getGrilleCategoriePaies();
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
          // Nouveau champ: numéro matricule
          SimpleTextField(
            label: "Numéro matricule",
            textController: _numeroMatriculeController,
          ),
          // Nouveau dropdown: moyen de paiement
          FutureCustomDropDownField<MoyenPaiementModel>(
            label: "Moyen de paiement",
            selectedItem: moyenPaiement,
            fetchItems: fetchMoyenPaiementItems,
            onChanged: (MoyenPaiementModel? value) {
              setState(() {
                moyenPaiement = value;
              });
            },
            canClose: true,
            itemsAsString: (s) => s.libelle,
          ),
          FutureCustomDropDownField<OperateurModel>(
            label: "Opérateur",
            selectedItem: _operateur,
            fetchItems: fetchOperateurItems,
            onChanged: (OperateurModel? value) {
              if (value != null) {
                setState(() {
                  _operateur = value;
                });
              }
            },
            canClose: true,
            itemsAsString: (s) => s.libelle,
          ),

          SimpleTextField(
            label: "Numéro de compte",
            textController: _numeroDeCompteController,
            required: false,
          ),
          FutureCustomDropDownField<CategoriePaieModel>(
            label: "Catégorie de paie",
            selectedItem: categoriePaie,
            fetchItems: fetchPaieCategorieItems,
            onChanged: (CategoriePaieModel? value) {
              setState(() {
                categoriePaie = value;
              });
            },
            itemsAsString: (r) => r.categoriePaie,
          ),
          // Ajout sélection grille/classe/échelon
          FutureCustomDropDownField<GrilleCategoriePaieModel>(
            label: "Categorie de paie (Grille)",
            selectedItem: grilleCategoriePaie,
            fetchItems: _fetchGrilleCategoriePaieItems,
            onChanged: (GrilleCategoriePaieModel? value) {
              setState(() {
                grilleCategoriePaie = value;
                classe = null;
                echelon = null;
              });
            },
            itemsAsString: (r) => r.libelle,
          ),
          if (grilleCategoriePaie != null)
            CustomDropDownField(
              items: grilleCategoriePaie!.classes ?? [],
              selectedItem: classe,
              onChanged: (value) {
                setState(() {
                  classe = value;
                  echelon = null;
                });
              },
              label: "Classe",
              itemsAsString: (classe) => classe.libelle,
            ),
          if (classe != null && classe!.echelonIndiciciaires != null)
            CustomDropDownField(
              items: classe!.echelonIndiciciaires!.map((echelonIndiciaire) {
                return echelonIndiciaire.echelon;
              }).toList(),
              onChanged: (value) {
                setState(() {
                  echelon = value!;
                });
              },
              selectedItem: echelon,
              label: "Echelon",
              itemsAsString: (echelon) {
                return echelon.libelle;
              },
            ),
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
      throw ("Veuillez sélectionner un personnel et une catégorie de paie.");
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
