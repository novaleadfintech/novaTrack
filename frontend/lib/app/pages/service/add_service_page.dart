import 'package:flutter/material.dart';
import 'package:frontend/model/pays_model.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/service/service_prix_model.dart';
import '../../../service/pays_service.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/service_prix_field.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../global/constant/request_management_value.dart';
import '../../../model/service/enum_service.dart';
import '../../../service/service_service.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';

class AddServicePage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddServicePage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  PaysModel? _selectedCountry;
  final List<Map<String, dynamic>> _tarifControllers = [];

  ServiceType? type;
  NatureService? nature;

  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> addService() async {
    final libelle = _libelleController.text.trim();
    String errorMessage = "";
    final description = _descriptionController.text.trim();
    final prix = _prixController.text.trim();

    if (type == null ||
        nature == null ||
        libelle.isEmpty ||
        _selectedCountry == null ||
        (nature == NatureService.unique && prix.isEmpty) ||
        (nature == NatureService.multiple && _tarifControllers.isEmpty)) {
      errorMessage = "Tous les champs marqués doivent être remplis";
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

        // Vérification des champs obligatoires (sauf max du dernier)
        if (minQuantity == null ||
            prix == null ||
            (i != _tarifControllers.length - 1 && maxQuantity == null)) {
          MutationRequestContextualBehavior.showCustomInformationPopUp(
            message:
                "Veuillez renseigner tous les champs des différentes tranches.",
          );
          return;
        }

        if (_tarifControllers.first["minQuantity"].text != "1" ||
            _tarifControllers.last["maxQuantity"].text.isNotEmpty) {
          MutationRequestContextualBehavior.showCustomInformationPopUp(
            message:
                "Le format des tranches est incorrect. Il doit commencer par 1 et se terminer par un champ vide.",
          );
          return;
        }

        // Vérification que min, max et prix ne sont pas 0
        if (minQuantity == 0 ||
            prix == 0 ||
            (maxQuantity != null && maxQuantity == 0)) {
          errorMessage = "Aucune valeur des tranches ne doit être 0.";
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

        // Ajout à la liste si tout est valide
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

    _dialog.show(
      message: RequestMessage.loadinMessage,
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    try {
      var result = await ServiceService.createService(
      libelle: libelle,
      tarif: tarifModifies,
      type: type!,
      nature: nature!,
      prix: double.tryParse(prix),
      description: description.isNotEmpty ? description : null,
      country: _selectedCountry!,
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Service créé avec succès");
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

  Future<List<PaysModel>> fetchCountryItems() async {
    return await PaysService.getAllPays();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: UniqueKey(),
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
              items: ServiceType.values.map((e) => e).toList(),
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
              items: NatureService.values.map((e) => e).toList(),
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
              ServiceTariffields(controllers: _tarifControllers),
            SimpleTextField(
              label: "Description",
              textController: _descriptionController,
              expands: true,
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
                    addService();
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
