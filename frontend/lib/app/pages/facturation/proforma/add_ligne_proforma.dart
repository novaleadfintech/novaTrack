import 'package:flutter/material.dart';
 import 'package:frontend/model/pays_model.dart';
import 'package:frontend/model/service/enum_service.dart';
import '../../../../helper/frais_helper.dart';
 import '../../../../model/service/service_prix_model.dart';
import '../../../responsitvity/responsivity.dart';
import '../../../../global/constant/constant.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/facturation/frais_divers_model.dart';
import '../../../../model/service/service_model.dart';
import '../../../../model/request_response.dart';
import '../../../../service/ligne_proforma_service.dart';
import '../../../../service/service_service.dart';
import '../../../../widget/drop_down_text_field.dart';
import '../../../../widget/duration_field.dart';
import '../../../../widget/frais_divers_space.dart';
import '../../../../widget/simple_text_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../widget/future_dropdown_field.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';

class AddLigneProforma extends StatefulWidget {
  final String proformaId;
  final PaysModel pays;
  final Future<void> Function() refresh;
  const AddLigneProforma({
    super.key,
    required this.proformaId,
    required this.pays,
    required this.refresh,
  });

  @override
  State<AddLigneProforma> createState() => _AddLigneProformaState();
}

class _AddLigneProformaState extends State<AddLigneProforma> {
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
  Future<void> addLigneProforma() async {
    final designation = _designationController.text.trim();
    final quantiteString = _quantiteController.text.trim();
    // final remiseString = _remiseController.text.trim();
    final prixSupplementaireString = _prixSupplementaireController.text.trim();
    final compterString = _compterController.text.trim();
    String errorMessage = "";

    // Vérification des champs obligatoires
    if (service == null ||
        designation.isEmpty ||
        _unitController.text.trim().isEmpty ||
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
    if ((compteur != null && unit == null) ||
        compteur == null && unit != null) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage:
            "Veuillez remplir les deux champs de durée de livraison.",
      );
    }
    RequestResponse result = await LigneProformaService.createLigneProforma(
      proformaId: widget.proformaId,
      unit: _unitController.text,
      serviceId: service!.id,
      prixSupplementaire: (prixSupplementaireString.isEmpty)
          ? null
          : double.parse(prixSupplementaireString),
      designation: designation,
      dureeLivraison: unit != null && compteur != null
          ? compteur! * unitMultipliers[unit!]!
          : null,
      quantite: (quantiteString.isEmpty) ? null : int.parse(quantiteString),
      // remise: remiseString.isEmpty ? null : double.parse(remiseString),
      fraisDivers: _fraisDiversControllers.isEmpty ? null : frais,
    );
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Demande enrégistrer avec succès",
      );
      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }

  Future<List<ServiceModel>> fetchItemsService() async {
    List<ServiceModel> services = await ServiceService.getUnarchivedService();
    return services.where((service) {
      String countryFilter = widget.pays.name;
      bool isTheSameType = false;
      isTheSameType = (service.type == ServiceType.punctual) ||
          (service.type == ServiceType.produit);
      return service.country.name == countryFilter && isTheSameType;
    }).toList();
  }

  @override
  void initState() {
    _quantiteController.text = "1";
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _quantiteController.addListener(_onQuantityChanged);
    super.initState();
  }

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
        if (tarif != null) {
          _prixController.text = tarif.prix.toString();
        } else {
          _prixController.text = 0.toString();
        }
      }
    } else {
      _prixController.text = "";
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
              FutureCustomDropDownField<ServiceModel>(
                label: "Service",
                selectedItem: service,
                fetchItems: fetchItemsService,
                onChanged: (ServiceModel? value) {
                  if (value != null) {
                    setState(() {
                      service = value;
                      _designationController.text = service!.libelle;
                      _quantiteController.text = "1";
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
                  textController: _prixSupplementaireController,
                  keyboardType: TextInputType.number,
                  readOnly: false,
                  required: false,
                ),
              Row(
                children: [
                  Expanded(
                    child: SimpleTextField(
                      label: "Quantité",
                      keyboardType: TextInputType.number,
                      textController: _quantiteController,
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
              // Ajouter le widget FraisDiversFields ici
              FraisDiversFields(
                controllers: _fraisDiversControllers,
              ),
              const Gap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ValidateButton(onPressed: addLigneProforma),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
