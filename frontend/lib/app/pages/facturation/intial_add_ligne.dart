import 'package:flutter/material.dart';
import 'package:frontend/dto/facturation/frais_divers_dto.dart';
import 'package:frontend/dto/facturation/ligne_dto.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../global/constant/constant.dart';
import '../../../helper/date_helper.dart';
import '../../../helper/frais_helper.dart';
import '../../../model/facturation/enum_facture.dart';
import '../../../model/pays_model.dart';
import '../../../model/service/enum_service.dart';
import '../../../model/service/service_model.dart';
import '../../../model/service/service_prix_model.dart';
import '../../../service/service_service.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/duration_field.dart';
import '../../../widget/frais_divers_space.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../responsitvity/responsivity.dart';

class AddInitialLigne extends StatefulWidget {
  final VoidCallback refresh;
  final TypeFacture type;
  final List<LigneDto> controllers;
  final PaysModel country;

  const AddInitialLigne({
    super.key,
    required this.controllers,
    required this.refresh,
    required this.type,
    required this.country,
  });

  @override
  State<AddInitialLigne> createState() => _AddInitialLigneServiceState();
}

class _AddInitialLigneServiceState extends State<AddInitialLigne> {
  ServiceModel? service;
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  // final TextEditingController _remiseController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _prixSupplementaireController =
      TextEditingController();

  final TextEditingController _compterController = TextEditingController();
  String? unit;
  int? compteur;

  final List<Map<String, dynamic>> _fraisDiversControllers = [];
  late SimpleFontelicoProgressDialog _dialog;

  void _onQuantityChanged() {
    int? quantite = int.tryParse(_quantiteController.text);
    if (quantite != null && service != null) {
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
      _prixController.text = "";
    }
    setState(() {});
  }

  Future<void> addLigneService() async {
    try {
      final designation = _designationController.text.trim();
      final quantiteString = _quantiteController.text.trim();
      // final remiseString = _remiseController.text.trim();
      final compterString = _compterController.text.trim();
      final prixSupplementaireString =
          _prixSupplementaireController.text.trim();

      String errorMessage = "";

      // Vérification des champs obligatoires
      if (_unitController.text.trim().isEmpty ||
          service == null ||
          designation.isEmpty ||
          quantiteString.isEmpty) {
        errorMessage = "Tous les champs marqués doivent être remplis.";
      }
      if (int.parse(quantiteString) == 0) {
        errorMessage = "la quantité doit etre supperieur à 0";
      }
      if (errorMessage.isNotEmpty) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: errorMessage,
        );
        return;
      }
      List<FraisDiversDto>? frais;
      try {
        frais = convertFraisDiversDtoList(_fraisDiversControllers);
      } catch (e) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
            message: e.toString());
        return;
      }
      
      compteur = int.tryParse(compterString);
      if ((compteur != null && unit == null) ||
          compteur == null && unit != null) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.customError,
          customMessage:
              "Veuillez remplir les deux champs de durée de livraison.",
        );
        return;
      }
      if (widget.controllers.any((ligne) => ligne.serviceId == service!.id)) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.customError,
          customMessage:
              "Ajout Impossible! Ce service a été déjà ajouté à cette facture.",
        );
        return;
      }
      _dialog.show(
        message: "",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );
      widget.controllers.add(
        LigneDto(
          designation: designation,
          dureeLivraison: unit != null && compteur != null
              ? compteur! * unitMultipliers[unit!]!
              : null,
          fraisDivers: _fraisDiversControllers.isEmpty ? [] : frais,
          prixSupplementaire: (prixSupplementaireString.isEmpty)
              ? null
              : double.parse(prixSupplementaireString),
          quantite: int.parse(quantiteString),
          unit: _unitController.text,
          serviceId: service!.id,
          service: service,
        ),
      );
      _dialog.hide();
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Demande enrégistrée avec succès",
      );
      widget.refresh();
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: e.toString(),
      );
     
    }
  }

  Future<List<ServiceModel>> fetchItemsService() async {
    List<ServiceModel> services = await ServiceService.getUnarchivedService();
    return services.where((service) {
      String countryFilter = widget.country.name;
      bool isTheSameType = false;
      if (widget.type == TypeFacture.recurrent) {
        isTheSameType = service.type == ServiceType.recurrent;
      } else {
        isTheSameType = service.type != ServiceType.recurrent;
      }
      return service.country.name == countryFilter && isTheSameType;
    }).toList();
  }

  @override
  void initState() {
    _quantiteController.text = "1";
    _quantiteController.addListener(_onQuantityChanged);
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: SingleChildScrollView(
        child: Form(
          // key: UniqueKey(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FutureCustomDropDownField<ServiceModel>(
                label: "Service",
                selectedItem: service,
                fetchItems: fetchItemsService,
                onChanged: (ServiceModel? value) {
                  if (value != null) {
                    setState(() {
                      service = value;
                      _designationController.text = service!.libelle;
                      _onQuantityChanged();
                    });
                  }
                },
                itemsAsString: (s) => s.libelle,
              ),
              SimpleTextField(
                label: "Designation",
                textController: _designationController,
              ),
              Row(
                children: [
                  Expanded(
                    child: SimpleTextField(
                      label: "prix",
                      textController: _prixController,
                      readOnly: true,
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    Expanded(
                      child: SimpleTextField(
                        label: "prix supplementaire",
                        textController: _prixSupplementaireController,
                        keyboardType: TextInputType.number,
                        readOnly: false,
                        required: false,
                      ),
                    ),
                ],
              ),
              if (Responsive.isMobile(context))
                SimpleTextField(
                  label: "prix supplementaire",
                  keyboardType: TextInputType.number,
                  textController: _prixSupplementaireController,
                  readOnly: false,
                  required: false,
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
                            if (value != null) {
                              _unitController.text = value;
                            }
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
                      if (value != null) {
                        _unitController.text = value;
                      }
                    });
                  },
                  canClose: false,
                  label: "Unité",
                  selectedItem: _unitController.text,
                ),
              if (_unitController.text == 'Autre')
                SimpleTextField(
                  label: "Autre unité",
                  textController: _unitController,
                  required: true,
                ),
              // SimpleTextField(
              //   label: "Remise",
              //   textController: _remiseController,
              //   required: false,
              //   inputFormaters: [FilteringTextInputFormatter.digitsOnly],
              // ),
              DurationField(
                controller: _compterController,
                label: "Durée de livraison",
                onUnityChanged: (value) {
                  setState(
                    () {
                      unit = value;
                    },
                  );
                },
                unitSelectItem: unit,
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
                  child: ValidateButton(onPressed: addLigneService),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
