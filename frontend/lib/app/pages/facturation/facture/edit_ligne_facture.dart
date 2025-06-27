import 'package:flutter/material.dart';
import 'package:frontend/model/pays_model.dart';
import 'package:frontend/model/service/enum_service.dart';
import '../../../../helper/frais_helper.dart';
import '../../../../model/facturation/ligne_model.dart';
import '../../../../model/service/service_prix_model.dart';
import '../../../responsitvity/responsivity.dart';
import '../../../../global/constant/constant.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/facturation/frais_divers_model.dart';
 import '../../../../model/service/service_model.dart';
import '../../../../model/request_response.dart';
import '../../../../service/ligne_facture_service.dart';
import '../../../../widget/drop_down_text_field.dart';
import '../../../../widget/duration_field.dart';
import '../../../../widget/frais_divers_space.dart';
import '../../../../widget/simple_text_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';

class UpdateLigneFacture extends StatefulWidget {
  final LigneModel ligneFacture;
  final PaysModel pays;
  final Future<void> Function() refresh;

  const UpdateLigneFacture({
    super.key,
    required this.ligneFacture,
    required this.pays,
    required this.refresh,
  });

  @override
  State<UpdateLigneFacture> createState() => _UpdateLigneFactureState();
}

class _UpdateLigneFactureState extends State<UpdateLigneFacture> {
  late ServiceModel? service;
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  // final TextEditingController _remiseController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _compterController = TextEditingController();
  final TextEditingController _prixSupplementaireController =
      TextEditingController();

  String? dureeUnit;
  int? compteur;
  final List<Map<String, dynamic>> _fraisDiversControllers = [];
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _quantiteController.addListener(_onQuantityChanged);
    // Charger les données de la ligne de service
    service = widget.ligneFacture.service!;
    _designationController.text = widget.ligneFacture.designation;
    _quantiteController.text = widget.ligneFacture.quantite.toString();
    // _remiseController.text = widget.ligneFacture.remise.toString();
    _unitController.text = widget.ligneFacture.unit!;

    _prixController.text = widget.ligneFacture.service!.nature ==
            NatureService.unique
        ? widget.ligneFacture.service!.prix?.toString() ?? ""
        : service!.tarif
                .firstWhere(
                  (tarif) {
                    if (tarif!.maxQuantity == null) {
                      return widget.ligneFacture.quantite! >= tarif.minQuantity;
                    } else {
                      return widget.ligneFacture.quantite! >=
                              tarif.minQuantity &&
                          widget.ligneFacture.quantite! <= tarif.maxQuantity!;
                    }
                  },
                  orElse: () => ServiceTarifModel(
                    minQuantity: 1,
                    prix: 0, // Mettre null pour éviter 0 si non souhaité
                  ),
                )
                ?.prix // Vérifie que `prix` existe
                .toString() ??
            ""; // S

    _prixSupplementaireController.text =
        widget.ligneFacture.prixSupplementaire != null
            ? widget.ligneFacture.prixSupplementaire.toString()
            : "";
    if (widget.ligneFacture.dureeLivraison != null) {
      _compterController.text = convertDuration(
        durationMs: widget.ligneFacture.dureeLivraison!,
      ).compteur.toString();
      dureeUnit = convertDuration(
        durationMs: widget.ligneFacture.dureeLivraison!,
      ).unite;
    } else {
      _compterController.text = '';
      dureeUnit = null;
    }
    // _fraisDiversControllers.clear();
    for (var frais in widget.ligneFacture.fraisDivers!) {
      _fraisDiversControllers.add({
        'libelle': TextEditingController(text: frais.libelle),
        'montant': TextEditingController(text: frais.montant.toString()),
        'tva': frais.tva,
      });
    }
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> updateLigneFacture() async {
    try {
      final designation = _designationController.text.trim();
      final quantiteString = _quantiteController.text.trim();
      // final remiseString = _remiseController.text.trim();
      final compterString = _compterController.text.trim();
      final prixSupplementaireString =
          _prixSupplementaireController.text.trim();

      // Vérification des erreurs
      String errorMessage = "";
      if (designation.isEmpty ||
          quantiteString.isEmpty ||
          _unitController.text.trim().isEmpty) {
        errorMessage = "Tous les champs marqués doivent être remplis.";
      }
      if (int.parse(quantiteString) == 0) {
        errorMessage = "la quantité doit etre supperieur à 0";
      }

      if ((dureeUnit != null && compterString.isEmpty) ||
          (compterString.isNotEmpty && dureeUnit == null)) {
        errorMessage = "Renseigner et l'unité et le compteur";
      }
      if (errorMessage.isNotEmpty) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: errorMessage,
        );
        return;
      }

      bool hasFraisChanged = _fraisDiversControllers.length !=
              widget.ligneFacture.fraisDivers!.length ||
          _fraisDiversControllers.asMap().entries.any((entry) {
            final index = entry.key;
            final fraisController = entry.value;
            final fraisOriginal = widget.ligneFacture.fraisDivers![index];

            return fraisController['libelle']!.text != fraisOriginal.libelle ||
                fraisController['montant']!.text !=
                    fraisOriginal.montant.toString() ||
                fraisController['tva'] != fraisOriginal.tva;
          });
      bool hasChanged = designation != widget.ligneFacture.designation ||
          quantiteString != widget.ligneFacture.quantite.toString() ||
          _unitController.text != widget.ligneFacture.unit ||
          _compterController.text !=
              (widget.ligneFacture.dureeLivraison != null
                  ? convertDuration(
                      durationMs: widget.ligneFacture.dureeLivraison!,
                    ).compteur.toString()
                  : "") ||
          dureeUnit !=
              (widget.ligneFacture.dureeLivraison != null
                  ? convertDuration(
                      durationMs: widget.ligneFacture.dureeLivraison!,
                    ).unite
                  : "");
      prixSupplementaireString !=
          (widget.ligneFacture.prixSupplementaire?.toString() ?? "");

      if (!hasChanged && !hasFraisChanged) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Aucune modification n'a été effectuée.",
        );
        return;
      }
      List<FraisDiversModel>? frais;
      try {
        frais = convertFraisDiversList(_fraisDiversControllers);
      } catch (e) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
            message: e.toString());
        return;
      }
      _dialog.show(
        message: "",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      compteur = int.tryParse(compterString);
      if ((compteur != null && dureeUnit == null) ||
          compteur == null && dureeUnit != null) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.customError,
          customMessage:
              "Veuillez remplir les deux champs de durée de livraison.",
        );
      }
      RequestResponse result = await LigneFactureService.updateLigneFacture(
        ligneFactureId: widget.ligneFacture.id,
        unit: _unitController.text,
        prixSupplementaire: prixSupplementaireString.isEmpty
            ? null
            : double.parse(prixSupplementaireString),
        serviceId: service == widget.ligneFacture.service ? null : service!.id,
        designation: designation,
        dureeLivraison: dureeUnit == null || compteur == null
            ? null
            : compteur! * unitMultipliers[dureeUnit!]!,
        quantite: (quantiteString.isEmpty) ? null : int.parse(quantiteString),
        // remise: remiseString.isEmpty ? null : double.parse(remiseString),
        fraisDivers: _fraisDiversControllers.isEmpty ? null : frais,
      );

      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Ligne de service mise à jour avec succès",
        );
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
        return;
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: "Erreur lors de la mise à jour",
      );
      return;
    }
  }

  // Future<List<ServiceModel>> fetchItemsService() async {
  //   List<ServiceModel> services = await ServiceService.getUnarchivedService();
  //   return services.where((service) {
  //     bool isTheSameType = false;
  //     if (widget.type == TypeFacture.recurrent) {
  //       isTheSameType = service.type == ServiceType.recurrent;
  //     } else {
  //       isTheSameType = service.type != ServiceType.recurrent;
  //     }
  //     return service.country.name == countryFilter && isTheSameType;
  //     return service.country.name == widget.pays.name;
  //   }).toList();
  // }

  void _onQuantityChanged() {
    int? quantite = int.tryParse(_quantiteController.text);
    if (quantite != null) {
      if (service!.nature == NatureService.unique) {
        _prixController.text = service!.prix.toString();
      } else {
        final tarif = service!.tarif.firstWhere(
          (tarif) {
            if (tarif!.maxQuantity == null) {
              return quantite >= tarif.minQuantity;
            } else {
              return quantite >= tarif.minQuantity &&
                  quantite <= tarif.maxQuantity!;
            }
          },
          orElse: () => ServiceTarifModel(minQuantity: 1, prix: 0),
        );
        _prixController.text = tarif!.prix.toString();
      }
    } else {
      _prixController.text = (service!.prix ?? "").toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: SingleChildScrollView(
        child: Form(
          key: UniqueKey(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomDropDownField<ServiceModel>(
                label: "Service",
                selectedItem: service,
                items: [widget.ligneFacture.service!],
                onChanged: (ServiceModel? value) {
                  if (value != null) {
                    setState(() {
                      service = value;
                      _designationController.text = service!.libelle;
                      _onQuantityChanged();
                    });
                  }
                },
                canClose: false,
                itemsAsString: (s) => s.libelle,
              ),
              SimpleTextField(
                label: "Désignation",
                textController: _designationController,
              ),
              Row(
                children: [
                  Expanded(
                    child: SimpleTextField(
                      label: "Quantité",
                      textController: _quantiteController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    Expanded(
                      child: CustomDropDownField<String>(
                        items: Constant.units,
                        onChanged: (String? value) {
                          setState(() {
                            _unitController.text = value!;
                          });
                        },
                        canClose: false,
                        label: "Unité",
                        selectedItem: _unitController.text,
                      ),
                    ),
                ],
              ),
              if (Responsive.isMobile(context))
                CustomDropDownField<String>(
                  items: Constant.units,
                  onChanged: (String? value) {
                    setState(() {
                      _unitController.text = value!;
                    });
                  },
                  label: "Unité",
                  selectedItem: _unitController.text,
                ),
              if (_unitController.text == 'Autre')
                SimpleTextField(
                  label: "Autre unité",
                  textController: _unitController,
                  required: true,
                ),
              Row(
                children: [
                  Expanded(
                    child: SimpleTextField(
                      label: "Prix",
                      textController: _prixController,
                      readOnly: true,
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    Expanded(
                      child: SimpleTextField(
                        label: "Prix supplementaire",
                        textController: _prixSupplementaireController,
                        keyboardType: TextInputType.number,
                        // keyboardType:
                        //     const TextInputType.numberWithOptions(decimal: true),
                        readOnly: false,
                        required: false,
                      ),
                    ),
                ],
              ),
              if (Responsive.isMobile(context))
                SimpleTextField(
                  label: "Prix supplementaire",
                  textController: _prixSupplementaireController,
                  keyboardType: TextInputType.number,
                  // keyboardType:
                  //     const TextInputType.numberWithOptions(decimal: true),
                  readOnly: false,
                  required: false,
                ),
              // SimpleTextField(
              //   label: "Remise",
              //   textController: _remiseController,
              //   required: false,
              //   inputFormaters: [FilteringTextInputFormatter.digitsOnly],
              //   keyboardType:
              //       const TextInputType.numberWithOptions(decimal: true),
              // ),
              DurationField(
                controller: _compterController,
                label: "Durée de livraison",
                onUnityChanged: (value) {
                  setState(() {
                    dureeUnit = value;
                  });
                },
                unitSelectItem: dureeUnit,
                required: false,
              ),
              FraisDiversFields(
                controllers: _fraisDiversControllers,
              ),
              const Gap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ValidateButton(onPressed: updateLigneFacture),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
