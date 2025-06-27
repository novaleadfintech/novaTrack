import 'package:flutter/material.dart';
import '../../../../model/facturation/reduction_model.dart';
import '../../../../widget/reduction_field.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/client/client_model.dart';
import '../../../../model/facturation/proforma_model.dart';
import '../../../../model/request_response.dart';
import '../../../../service/client_service.dart';
import '../../../../service/proforma_service.dart';
import '../../../../widget/custom_radio_yer_or_no.dart';
import '../../../../widget/date_text_field.dart';
import '../../../../widget/duration_field.dart';
import '../../../../widget/future_dropdown_field.dart';
import '../../../../widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class EditProformat extends StatefulWidget {
  final Future<void> Function() refresh;
  final ProformaModel proforma;

  const EditProformat({
    super.key,
    required this.refresh,
    required this.proforma,
  });

  @override
  State<EditProformat> createState() => _EditProformatState();
}

class _EditProformatState extends State<EditProformat> {
  final TextEditingController _dateEtablissementController =
      TextEditingController();
  final TextEditingController _dateEnvoieController = TextEditingController();
  final TextEditingController _compterController = TextEditingController();
  final TextEditingController _reductionController = TextEditingController();
  ClientModel? client;
  String? newClientId;
  DateTime? dateEtablissement;
  DateTime? dateEnvoie;
  bool tva = false;
  double? reduction;

  String? unit;
  int? garantyPeriode;
  late SimpleFontelicoProgressDialog _dialog;
  String? selectedFilter;
  List<String> selectedFilterOption = [
    "",
    "%",
  ];

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _dateEtablissementController.text =
        getStringDate(time: widget.proforma.dateEtablissementProforma!);
    if (widget.proforma.garantyTime != 0) {
      _dateEnvoieController.text = widget.proforma.dateEnvoie != null
          ? getStringDate(time: widget.proforma.dateEnvoie!)
          : '';
      _compterController.text = widget.proforma.garantyTime != null
          ? convertDuration(durationMs: widget.proforma.garantyTime!)
              .compteur
              .toString()
          : "";
      unit = widget.proforma.garantyTime != null
          ? convertDuration(durationMs: widget.proforma.garantyTime!).unite
          : "";
    }
    _reductionController.text = (widget.proforma.reduction!.valeur).toString();
    selectedFilter = widget.proforma.reduction!.unite;

    client = widget.proforma.client!;
    tva = widget.proforma.tva ?? false;
  }

  String? validateFields() {
    if (client == null ||
        _dateEnvoieController.text.isEmpty ||
        _dateEtablissementController.text.isEmpty) {
      return "Veillez remplir tous les champ marqués";
    }
    bool isGarantieFilled = unit != null && _compterController.text.isNotEmpty;
    if (isGarantieFilled) {
      garantyPeriode =
          int.parse(_compterController.text) * unitMultipliers[unit]!;
    } else {
      return "Veuillez remplir les deux champs de garantie (unité et compteur).";
    }
    if (isGarantieFilled == false) {
      return "Veillez remplir tous les champ marqués";
    }
    return null;
  }

  bool hasChanged() {
    if (_dateEtablissementController.text !=
            getStringDate(time: widget.proforma.dateEtablissementProforma!) ||
        (_dateEnvoieController.text.isNotEmpty &&
            _dateEnvoieController.text !=
                (widget.proforma.dateEnvoie != null
                    ? getStringDate(time: widget.proforma.dateEnvoie!)
                    : ''))) {
      return true;
    }

    if (client!.id != widget.proforma.client!.id) {
      return true;
    } else {
      newClientId = client!.id;
    }
    if (widget.proforma.reduction!.valeur !=
        double.tryParse(_reductionController.text)) {
      reduction = double.tryParse(_reductionController.text);
    } else {
      reduction = widget.proforma.reduction!.valeur;
    }
    if (widget.proforma.reduction!.unite == null && selectedFilter != "") {
      selectedFilter == selectedFilter;
    }
    // // Comparer la TVA
    if (tva != (widget.proforma.tva ?? false)) {
      return true;
    }

    // // Comparer l'unité de garantie et le compteur
    if (_compterController.text !=
            (convertDuration(durationMs: widget.proforma.garantyTime!)
                .compteur
                .toString()) ||
        unit !=
            convertDuration(durationMs: widget.proforma.garantyTime!).unite) {
      return true;
    }
    if (widget.proforma.reduction!.unite != selectedFilter) {
      return true;
    }

    return false;
  }

  // Fonction pour mettre à jour la proforma
  updateProformat() async {
    try {
      if (selectedFilter == "") {
        selectedFilter = null;
      }

      String? errMessage = validateFields();
      if (errMessage != null) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: errMessage,
        );
        return;
      }
      bool hasChange = hasChanged();
      if (!hasChange) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Aucune modification n'a été faite",
        );
        return;
      }
      _dialog.show(
        message: "",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await ProformaService.updateProformat(
        id: widget.proforma.id,
        dateEtablissementProforma: dateEtablissement,
        clientId: client!.id,
        dateEnvoie: dateEnvoie,
        garantie: garantyPeriode,
        tva: tva,
        reduction: reduction == null && selectedFilter == null
            ? null
            : reduction != null
                ? ReductionModel(
                    unite: selectedFilter,
                    valeur: reduction ?? 0,
                  )
                : null,
      );
      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Proforma mis à jour avec succès",
        );
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
        return;
      }
    } catch (err) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: err.toString(),
      );
    }
  }

  void onSelected(String value) {
    setState(() {
      selectedFilter =
          selectedFilterOption.firstWhere((element) => element == value);
    });
  }

  Future<List<ClientModel>> fetchItems() async {
    return await ClientService.getUnarchivedClientsAndProspects();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: UniqueKey(),
        child: Column(
          children: [
            FutureCustomDropDownField<ClientModel>(
              label: "Client",
              selectedItem: client,
              fetchItems: fetchItems,
              onChanged: (ClientModel? value) {
                if (value != null) {
                  setState(() {
                    client = value;
                  });
                }
              },
              itemsAsString: (c) => c.toStringify(),
            ),
            ReductionField(
              label: selectedFilter,
              onSelected: onSelected,
              reductionController: _reductionController,
            ),
            DateField(
              onCompleteDate: (value) {
                setState(() {
                  dateEtablissement = value!;
                  _dateEtablissementController.text =
                      getStringDate(time: value);
                });
              },
              lastDate:
                  (dateEnvoie != null && dateEnvoie!.isBefore(DateTime.now()))
                      ? dateEnvoie
                      : DateTime.now(),
              label: "Date d'établissement",
              dateController: _dateEtablissementController,
            ),
            CustomRadioGroup(
              label: "Appliquer la TVA",
              groupValue: tva,
              onChanged: (bool? value) {
                setState(() {
                  tva = value!;
                });
              },
              defaultValue: false,
            ),
            DurationField(
              controller: _compterController,
              label: "Garantie",
              onUnityChanged: (value) {
                setState(() {
                  unit = value;
                });
              },
              unitSelectItem: unit,
            ),
            DateField(
              onCompleteDate: (value) {
                setState(() {
                  dateEnvoie = value!;
                  _dateEnvoieController.text = getStringDate(time: value);
                });
              },
              firstDate: dateEnvoie,
              label: "Date d'envoi",
              dateController: _dateEnvoieController,
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValidateButton(onPressed: updateProformat),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
