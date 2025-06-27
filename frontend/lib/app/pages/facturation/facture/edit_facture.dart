import 'package:flutter/material.dart';
import 'package:frontend/model/facturation/reduction_model.dart';
import 'package:frontend/service/banque_service.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../model/entreprise/banque.dart';
import '../../../../model/facturation/facture_acompte.dart';
import '../../../../widget/affiche_information_on_pop_pop.dart';
import '../../../../widget/facture_acompte_fields.dart';
import '../../../../widget/multiple_select_drop_down.dart';
import '../../../../widget/reduction_field.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/client/client_model.dart';
import '../../../../model/facturation/enum_facture.dart';
import '../../../../model/facturation/facture_model.dart';
import '../../../../model/request_response.dart';
import '../../../../service/facture_service.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../service/client_service.dart';
import '../../../../widget/custom_radio_yer_or_no.dart';
import '../../../../widget/date_text_field.dart';
import '../../../../widget/duration_field.dart';
import '../../../../widget/validate_button.dart';

class EditFacture extends StatefulWidget {
  final Future<void> Function() refresh;
  final FactureModel facture;
  const EditFacture({
    super.key,
    required this.refresh,
    required this.facture,
  });

  @override
  State<EditFacture> createState() => _EditFactureState();
}

class _EditFactureState extends State<EditFacture> {
  final TextEditingController _dateEtablissementController =
      TextEditingController();
  final TextEditingController _dateEnvoieFacture = TextEditingController();
  final TextEditingController _dateDebutFacturation = TextEditingController();
  final TextEditingController _reductionController = TextEditingController();
  final TextEditingController _compterController = TextEditingController();
  final MultiSelectController<BanqueModel> _comptesController =
      MultiSelectController<BanqueModel>();
  List<BanqueModel>? banques;
  bool tva = false;
  bool canPenalty = true;
  ClientModel? client;
  DateTime? dateEnvoieFacture;
  DateTime? dateEtablissement;
  DateTime? dateDebutFacturation;
  late TypeFacture type;
  String? unit;

  DateTime? newdateEtablissement;
  DateTime? newdatepayement;
  DateTime? newDateEnvoieFacture;
  DateTime? newdatedebutFacture;
  double? reduction;
  int? compteur;
  List<BanqueModel>? newBanques;
  ClientModel? newclient;
  TypeFacture? newtype;
  String? newunit;
  bool? newtva;
  int? regeneratePeriod;
  final List<Map<String, dynamic>> _factureAcompteController = [];
  final List<Map<String, dynamic>> _initialfactureAcompteController = [];

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
        getStringDate(time: widget.facture.dateEtablissementFacture!);

    _reductionController.text = (widget.facture.reduction!.valeur).toString();
    selectedFilter = widget.facture.reduction!.unite;
    dateEtablissement = widget.facture.dateEtablissementFacture;
    tva = widget.facture.tva!;
    type = widget.facture.type!;
    client = widget.facture.client;
    for (var acompte in widget.facture.facturesAcompte) {
      _initialfactureAcompteController.add({
        'rang': TextEditingController(text: "${acompte.rang}"),
        'canPenalty': acompte.canPenalty,
        'pourcentage': TextEditingController(text: "${acompte.pourcentage}"),
        'dateEnvoieFacture': TextEditingController(
            text: getStringDate(time: acompte.dateEnvoieFacture)),
      });
      _factureAcompteController.add({
        'rang': TextEditingController(text: "${acompte.rang}"),
        'pourcentage': TextEditingController(text: "${acompte.pourcentage}"),
        'canPenalty': acompte.canPenalty,
        'dateEnvoieFacture': TextEditingController(
            text: getStringDate(time: acompte.dateEnvoieFacture)),
      });
    }
    if (widget.facture.type == TypeFacture.recurrent) {
      dateEnvoieFacture = widget.facture.facturesAcompte[0].dateEnvoieFacture;
      _dateEnvoieFacture.text = getStringDate(time: dateEnvoieFacture!);
      dateDebutFacturation =
          widget.facture.dateDebutFacturation ?? DateTime.now();
      _dateDebutFacturation.text = getStringDate(time: dateDebutFacturation!);
      _compterController.text =
          convertDuration(durationMs: widget.facture.generatePeriod!)
              .compteur
              .toString();
      unit = convertDuration(durationMs: widget.facture.generatePeriod!).unite;
    }
  }

  void onSelected(String value) {
    setState(() {
      selectedFilter =
          selectedFilterOption.firstWhere((element) => element == value);
    });
  }

  bool areAllAccountsDisabled() {
    return _comptesController.items.every((item) => item.selected == false);
  }

  String? validateFields() {
    if (client == null || _dateEtablissementController.text.isEmpty) {
      return "Veuillez remplir tous les champs";
    }
    if (type == TypeFacture.recurrent &&
        (_dateDebutFacturation.text.isEmpty ||
            _dateEnvoieFacture.text.isEmpty ||
            _compterController.text.isEmpty ||
            unit == null ||
            banques == null)) {
      return "Veuillez remplir tous les champs marqués";
    }
    if (areAllAccountsDisabled()) {
      return "Veuillez sélectionner au moins un compte.";
    }
    if (type == TypeFacture.punctual) {
      int sommePourcentage = _factureAcompteController.fold(
        0,
        (somme, element) => somme + int.parse(element["pourcentage"].text),
      );
      if (sommePourcentage != 100) {
        return "Revoyez la repartition des pourcentage sur des factures d'accompte. La somme doit etre impérativement 100";
      }
    }
    return null;
  }

  bool hasFactureAcompteChanged(
      {required List<Map<String, dynamic>> initialList,
      required List<Map<String, dynamic>> finalList}) {
    for (var initial in initialList) {
      var finalState = finalList.firstWhere(
        (element) => element["rang"]?.text == initial["rang"]?.text,
        orElse: () => {},
      );
      if (finalState.isEmpty) return true;

      for (var key in initial.keys) {
        if (key != "canPenalty") {
          if (initial[key]?.text != finalState[key]?.text) {
            return true;
          }
        } else {
          if (initial[key] != finalState[key]) {
            return true;
          }
        }
      }
    }
    return false;
  }

  changeValue() {
    if (widget.facture.client != client) {
      newclient = client;
    }
    if (widget.facture.dateEtablissementFacture != dateEtablissement) {
      newdateEtablissement = dateEtablissement!;
    }

    if (widget.facture.reduction!.valeur !=
        double.tryParse(_reductionController.text)) {
      reduction = double.tryParse(_reductionController.text);
    } else {
      reduction = widget.facture.reduction!.valeur;
    }

    if (widget.facture.reduction!.unite == null && selectedFilter != "") {
      selectedFilter == selectedFilter;
    }
    if (widget.facture.tva != tva) {
      newtva = tva;
    }

    if (type == TypeFacture.recurrent) {
      if (widget.facture.dateDebutFacturation != dateDebutFacturation) {
        newdatedebutFacture = dateDebutFacturation;
      }

      if (widget.facture.facturesAcompte[0].dateEnvoieFacture !=
          dateEnvoieFacture) {
        newDateEnvoieFacture = dateEnvoieFacture!;
      }
      if (widget.facture.generatePeriod !=
          int.parse(_compterController.text) * unitMultipliers[unit]!) {
        regeneratePeriod =
            int.parse(_compterController.text) * unitMultipliers[unit]!;
      }
    }
  }

  bool isBanqueEqual({
    required List<BanqueModel>? list1,
    required List<BanqueModel>? list2,
  }) {
    if (list1 == null || list2 == null) return list1 == list2;
    if (list1.length != list2.length) return false;
    final set1 = list1.map((item) => item.id).toSet();
    final set2 = list2.map((item) => item.id).toSet();
    return set1.containsAll(set2) && set2.containsAll(set1);
  }

  bool hasChanges() {
    if (widget.facture.client != client ||
        widget.facture.dateEtablissementFacture != dateEtablissement ||
        widget.facture.reduction!.valeur !=
            double.tryParse(_reductionController.text) ||
        widget.facture.tva != tva ||
        widget.facture.reduction!.unite != selectedFilter) {
      return true;
    }
    if (newBanques != null &&
        !isBanqueEqual(list2: widget.facture.banques, list1: newBanques)) {
      return true;
    }
    if (hasFactureAcompteChanged(
        finalList: _factureAcompteController,
        initialList: _initialfactureAcompteController)) {
      return true;
    }
    if (type == TypeFacture.recurrent) {
      if (widget.facture.dateDebutFacturation != dateDebutFacturation ||
          widget.facture.facturesAcompte[0].dateEnvoieFacture !=
              dateEnvoieFacture ||
          widget.facture.facturesAcompte[0].canPenalty != canPenalty ||
          widget.facture.generatePeriod !=
              int.parse(_compterController.text) * unitMultipliers[unit]!) {
        return true;
      }
    }
    return false;
  }

  updateFacture() async {
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

    if (!hasChanges()) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Aucune modification n'a été apportée.",
      );
      return;
    } else {
      changeValue();
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    RequestResponse result = await FactureService.updateFacture(
      factureId: widget.facture.id,
      clientId: newclient?.id,
      tva: newtva,
      dateEtablissement: newdateEtablissement,
      reduction: reduction == null && selectedFilter == null
          ? null
          : reduction != null
              ? ReductionModel(
                  unite: selectedFilter,
                  valeur: reduction ?? 0,
                )
              : null,
      dateDebutFacturation: newdatedebutFacture,
      generatePeriod: regeneratePeriod,
      banques: newBanques,
      facturesAcompte: widget.facture.type == TypeFacture.punctual
          ? _factureAcompteController
              .map(
                (factureAcompte) => FactureAcompteModel(
                  rang: int.parse(factureAcompte["rang"]!.text),
                  canPenalty: factureAcompte["canPenalty"],
                  pourcentage: int.parse(factureAcompte["pourcentage"]!.text),
                  dateEnvoieFacture: convertToDateTime(
                    factureAcompte["dateEnvoieFacture"]!.text,
                  ),
                  isPaid: false,
                ),
              )
              .toList()
          : [
              FactureAcompteModel(
                rang: 1,
                pourcentage: 100,
                canPenalty: canPenalty,
                isPaid: false,
                dateEnvoieFacture: dateEnvoieFacture!,
              )
            ],
    );

    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Facture mise à jour avec succès",
      );
      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }

  Future<List<ClientModel>> fetchClientItems() async {
    return await ClientService.getUnarchivedClients();
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return await BanqueService.getAllBanques();
  }

  @override
  void dispose() {
    _dateEtablissementController.clear();
    _dateDebutFacturation.clear();
    _reductionController.clear();
    _compterController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: UniqueKey(),
        child: Column(
          children: [
            ShowInformation(
              content: widget.facture.client!.toStringify(),
              libelle: "Client",
            ),
            ReductionField(
              label: selectedFilter,
              onSelected: onSelected,
              reductionController: _reductionController,
            ),
            DateField(
              onCompleteDate: (value) {
                dateEtablissement = value!;
                _dateEtablissementController.text = getStringDate(time: value);
              },
              label: "Date d'établissement",
              lastDate: type == TypeFacture.recurrent
                  ? dateEnvoieFacture
                  : _factureAcompteController.isEmpty ||
                          _factureAcompteController
                              .first["dateEnvoieFacture"].text.isEmpty
                      ? DateTime.now()
                      : convertToDateTime(
                          _factureAcompteController
                              .first["dateEnvoieFacture"].text,
                        ),
              dateController: _dateEtablissementController,
              required: false,
            ),
            if (type == TypeFacture.recurrent) ...[
              DateField(
                onCompleteDate: (value) {
                  dateEnvoieFacture = value!;
                  _dateEnvoieFacture.text = getStringDate(time: value);
                },
                firstDate: dateEtablissement,
                label: "Date d'envoi",
                dateController: _dateEnvoieFacture,
              ),
            ],
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
            DefaultMultipleDropdownField<BanqueModel>(
              labelText: 'Comptes de payements',
              futureItems: fetchBanqueItems().then((banks) {
                final selectedBanques = widget.facture.banques;
                final selectedItems = selectedBanques!.map((selectedBanque) {
                  return DropdownItem<BanqueModel>(
                    label: selectedBanque.name,
                    value: selectedBanque,
                    selected: true,
                  );
                }).toList();

                if (mounted) {
                  setState(() {
                    banques = selectedBanques;
                  });
                }
                return banks.map((banque) {
                  return DropdownItem<BanqueModel>(
                    label: banque.name,
                    value: banque,
                    selected:
                        selectedItems.any((item) => item.value.id == banque.id),
                  );
                }).toList();
              }),
              enableSearch: true,
              onSelectionChange: (selectedbanque) {
                setState(() {
                  newBanques = selectedbanque;
                });
              },
              hintText: 'Choisissez un ou plusieurs comptes',
              maxItems: 3,
              controller: _comptesController,
            ),
            if (type == TypeFacture.punctual) ...[
              FactureAcompteFields(
                controllers: _factureAcompteController,
                dateEtablissement: dateEtablissement,
              ),
            ],
            if (type == TypeFacture.recurrent) ...[
              DateField(
                onCompleteDate: (value) {
                  dateDebutFacturation = value!;
                  _dateDebutFacturation.text = getStringDate(time: value);
                },
                label: "Date début facturation",
                dateController: _dateDebutFacturation,
              ),
              DurationField(
                controller: _compterController,
                label: "Période de regénération",
                onUnityChanged: (value) {
                  setState(() {
                    unit = value;
                  });
                },
                unitSelectItem: unit,
              ),
              CustomRadioGroup(
                label: "Appliquer les règles de pénalité",
                groupValue: canPenalty,
                onChanged: (bool? value) {
                  setState(() {
                    canPenalty = value!;
                  });
                },
                defaultValue: true,
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValidateButton(
                    onPressed: updateFacture,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
