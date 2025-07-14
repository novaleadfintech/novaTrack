import 'package:flutter/material.dart';
import 'package:frontend/model/pays_model.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../global/constant/request_management_value.dart';
import '../../../model/service/enum_service.dart';
import '../../../model/service/service_model.dart';
import '../../../model/service/service_prix_model.dart';
import '../../../service/pays_service.dart';
import '../../../service/service_service.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/service_prix_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class DuplicateServicePage extends StatefulWidget {
  final ServiceModel service;
  final Future<void> Function() refresh;
  const DuplicateServicePage({
    super.key,
    required this.service,
    required this.refresh,
  });

  @override
  State<DuplicateServicePage> createState() => _DuplicateServicePageState();
}

class _DuplicateServicePageState extends State<DuplicateServicePage> {
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  PaysModel? _selectedCountry;
  final List<Map<String, dynamic>> _tarifControllers = [];
  ServiceType? type;
  NatureService? nature;
  PaysModel? newCountry;
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _libelleController.text = widget.service.libelle;
    _prixController.text = widget.service.prix.toString();
    _descriptionController.text = (widget.service.description ?? '');
    _selectedCountry = widget.service.country;
    if (widget.service.tarif.isNotEmpty) {
      _tarifControllers.addAll(widget.service.tarif.map((e) => {
            "minQuantity":
                TextEditingController(text: e!.minQuantity.toString()),
            "maxQuantity": TextEditingController(
                text: e.maxQuantity != null ? e.maxQuantity.toString() : ""),
            "prix": TextEditingController(text: e.prix.toString()),
          }));
    }
    type = widget.service.type;
    nature = widget.service.nature;
  }

  Future<List<PaysModel>> fetchCountryItems() async {
    return await PaysService.getAllPays();
  }

  Future<void> editService() async {
    final libelle = _libelleController.text.trim();
    final prix = _prixController.text.trim();
    final description = _descriptionController.text.trim();
    String errorMessage = "";

    if (type == null ||
        libelle.isEmpty ||
        _selectedCountry == null ||
        (nature == NatureService.unique && prix.isEmpty) ||
        (nature == NatureService.multiple && _tarifControllers.isEmpty)) {
      errorMessage = "Tous les champs marqués doivent être remplis";
    }

    ServiceModel initialService = widget.service;

    if (nature == NatureService.unique) {
      if (double.tryParse(prix) == null) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Le prix doit être un nombre valide.",
        );
        return;
      }
    }

    final List<ServiceTarifModel> tarifModifies = [];
    if (nature == NatureService.multiple) {
      for (int i = 0; i < _tarifControllers.length; i++) {
        final minQuantity =
            int.tryParse(_tarifControllers[i]["minQuantity"].text.trim());
        final maxQuantity =
            int.tryParse(_tarifControllers[i]["maxQuantity"].text.trim());
        final prix = double.tryParse(
          _tarifControllers[i]["prix"].text.trim(),
        );

        if (minQuantity == null ||
            prix == null ||
            (i != _tarifControllers.length - 1 && maxQuantity == null)) {
          MutationRequestContextualBehavior.showCustomInformationPopUp(
            message:
                "Veuillez renseigner tous les champs des différentes tranches.",
          );
          return;
        }

        // Vérification que min, max et prix ne sont pas 0
        if (minQuantity == 0 ||
            prix == 0 ||
            (maxQuantity != null && maxQuantity == 0)) {
          errorMessage = "Aucune valeur des tranches ne doit être 0.";
        }

        if (_tarifControllers.first["minQuantity"].text != "1" ||
            _tarifControllers.last["maxQuantity"].text.isNotEmpty) {
          MutationRequestContextualBehavior.showCustomInformationPopUp(
            message:
                "Le format des tranches est incorrect. Il doit commencer par 1 et se terminer par un champ vide.",
          );
          return;
        }

        // Vérification que min < max (si max existe)
        if (maxQuantity != null && minQuantity >= maxQuantity) {
          errorMessage =
              "Toutes les valeurs min doivent être inférieures aux max.";
        }

        // Vérification de la continuité (min[i] == max[i-1] + 1)
        if (i > 0) {
          final previousMax = tarifModifies[i - 1].maxQuantity;
          if (previousMax != null && minQuantity != previousMax + 1) {
            errorMessage =
                "Le min du tarif ${i + 1} doit être égal à max du tarif $i + 1.";
          }
        }

        // Vérification du dernier élément : max peut être null
        if (i == _tarifControllers.length - 1 &&
            maxQuantity != null &&
            maxQuantity == 0) {
          errorMessage = "Le max du dernier tarif peut être vide mais pas 0.";
        }

        tarifModifies.add(ServiceTarifModel(
          minQuantity: minQuantity,
          maxQuantity: maxQuantity,
          prix: prix,
        ));
      }
    }

    if (errorMessage.isNotEmpty) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errorMessage,
      );
      return;
    }

    if (_selectedCountry != initialService.country) {
      newCountry = _selectedCountry;
    }

    if (newCountry == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez changer le pays.",
      );
      return;
    }

    _dialog.show(
      message: RequestMessage.loadinMessage,
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    // Envoi des modifications
    try {
      var result = await ServiceService.createService(
        libelle: libelle,
        tarif: tarifModifies,
        type: type!,
        nature: nature!,
        description: description.isEmpty ? null : description,
        country: newCountry!,
        prix: double.tryParse(prix),
      );

      _dialog.hide();

      // Gestion du résultat
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Service modifié avec succès",
        );
        await widget.refresh();
      } else {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        //key: UniqueKey(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SimpleTextField(
              label: "Libellé",
              textController: _libelleController,
            ),
            FutureCustomDropDownField<PaysModel>(
              label: "Pays",
              showSearchBox: true,
              selectedItem: _selectedCountry,
              fetchItems: fetchCountryItems,
              onChanged: (PaysModel? value) {
                if (value != null) {
                  setState(() {
                    _selectedCountry = value;
                  });
                }
              },
              canClose: false,
              itemsAsString: (s) => s.name,
            ),
            CustomDropDownField<ServiceType>(
              items: [type!],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                  });
                }
              },
              itemsAsString: (p0) => p0.label,
              selectedItem: type,
              label: "Type",
            ),
            CustomDropDownField<NatureService>(
              items: [nature!], // NatureService.values.map((e) => e).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    nature = value;
                    if (nature == NatureService.multiple) {
                      _prixController.clear();
                    } else {
                      _tarifControllers.clear();
                    }
                  });
                }
              },
              itemsAsString: (p0) => p0.label,
              selectedItem: nature,
              label: "Nature",
            ),
            if (nature == NatureService.unique)
              SimpleTextField(
                label: "Prix",
                textController: _prixController,
                keyboardType: TextInputType.number,
              ),
            if (nature == NatureService.multiple)
              ServiceTariffields(
                controllers: _tarifControllers,
              ),
            SimpleTextField(
              label: "Description",
              textController: _descriptionController,
              expands: true,
              // readOnly: true,
              required: false,
              maxLines: null,
              height: 80,
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () {
                    editService();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
