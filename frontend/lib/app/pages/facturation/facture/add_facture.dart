import 'package:flutter/material.dart';
import 'package:frontend/widget/facture_acompte_fields.dart';
import '../../../../dto/facturation/ligne_dto.dart';
import '../../../../model/entreprise/banque.dart';
import '../../../../model/facturation/facture_acompte.dart';
import '../../../../model/pays_model.dart';
import '../../../../service/banque_service.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/client/client_model.dart';
import '../../../../model/facturation/enum_facture.dart';
import '../../../../model/service/service_model.dart';
import '../../../../model/request_response.dart';
import '../../../../service/client_service.dart';
import '../../../../service/facture_service.dart';
import '../../../../service/pays_service.dart';
import '../../../../widget/custom_radio_yer_or_no.dart';
import '../../../../widget/date_text_field.dart';
import '../../../../widget/drop_down_text_field.dart';
import '../../../../widget/duration_field.dart';
import '../../../../widget/future_dropdown_field.dart';
import '../../../../widget/multiple_select_drop_down.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../initial_ligne_space.dart';

class AddFacture extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddFacture({
    super.key,
    required this.refresh,
  });

  @override
  State<AddFacture> createState() => _AddFactureState();
}

class _AddFactureState extends State<AddFacture> {
  final TextEditingController _dateEtablissementController =
      TextEditingController();
  final TextEditingController _dateEnvoieFacture = TextEditingController();
  final TextEditingController _dateDebutFacturation = TextEditingController();
  final TextEditingController _compterController = TextEditingController();
  final TextEditingController _delaicompterController = TextEditingController();
  final MultiSelectController<BanqueModel> _comptesController =
      MultiSelectController<BanqueModel>();
  List<BanqueModel>? banques;
  bool tva = false;
  bool canPenalty = true;
  ClientModel? client;
  ServiceModel? service;
  // DateTime? dateEcheantePayement;
  DateTime? dateEnvoieFacture;
  late DateTime dateEtablissement;
  DateTime? dateDebutFacturation = DateTime.now();
  TypeFacture type = TypeFacture.punctual;
  String? unit;
  String? delaiUnit;
  final List<Map<String, dynamic>> _factureAcompteControllers = [];
  PaysModel? _selectedCountry;
  final List<LigneDto> _initialLignesControllers = [];
  late SimpleFontelicoProgressDialog _dialog;

  bool hasclient = false;

  String? validateFields() {
    if (client == null ||
        _dateEtablissementController.text.isEmpty ||
        _comptesController.items.isEmpty ||
        _initialLignesControllers.isEmpty) {
      return "Veuillez remplir tous les champs marqués *";
    }

    if (type == TypeFacture.recurrent &&
        (_dateDebutFacturation.text.isEmpty ||
            _compterController.text.isEmpty ||
            _delaicompterController.text.isEmpty ||
            _dateEnvoieFacture.text.isEmpty ||
            unit == null ||
            delaiUnit == null)) {
      return "Vueillez remplir tous les champs marqués";
    }

    if (type == TypeFacture.punctual) {
      for (var toElement in _factureAcompteControllers) {
        var pourcentageController = toElement["pourcentage"];
        var dateController = toElement["dateEnvoieFacture"];

        if (pourcentageController == null ||
            pourcentageController.text.isEmpty ||
            int.tryParse(pourcentageController.text) == null) {
          return "Veuillez remplir tous les champs du pourcentage.";
        }

        if (dateController == null || dateController.text.isEmpty) {
          return "Veuillez renseigner une date d'envoi valide.";
        }
      }
      int sommePourcentage = _factureAcompteControllers.fold(
        0,
        (somme, element) => somme + int.parse(element["pourcentage"].text),
      );
      if (sommePourcentage != 100) {
        return "Revoyez la repartition des pourcentage sur des factures d'accompte. La somme doit etre impérativement 100";
      }
    }

    // if (type == TypeFacture.recurrent) {
    //   if (dateEnvoieFacture!.isAfter(dateEcheantePayement!)) {
    //     return "La date d'envoie de la facture ne doit pas supérieure au délai de paiement";
    //   }
    // }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    dateEtablissement = DateTime.now();
    _dateEtablissementController.text = getStringDate(time: dateEtablissement);
  }

  addFacture() async {
    String? errMessage = validateFields();
    if (errMessage != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errMessage,
      );
      return;
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    RequestResponse result = await FactureService.createFacture(
        clientId: client!.id,
        tva: tva,
        banques: banques!,
        type: type,
        dateDebutFacturation: dateDebutFacturation,
        dateEtablissementFacture: dateEtablissement,
        generatePeriod: type == TypeFacture.recurrent
            ? int.parse(_compterController.text) * unitMultipliers[unit]!
            : 0,
        delaisPayment: type == TypeFacture.recurrent
            ? int.parse(_delaicompterController.text) *
                unitMultipliers[delaiUnit]!
            : null,
        facturesAcompte: type == TypeFacture.punctual
            ? _factureAcompteControllers
                .map(
                  (factureAcompte) => FactureAcompteModel(
                    rang: int.parse(factureAcompte["rang"]!.text),
                    pourcentage: int.parse(factureAcompte["pourcentage"]!.text),
                    canPenalty: factureAcompte["canPenalty"]!,
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
                  isPaid: false,
                  canPenalty: canPenalty,
                  dateEnvoieFacture: dateEnvoieFacture!,
                )
              ],
        lignes: _initialLignesControllers);
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Facture enrégistrée avec succès",
      );

      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
      return;
    }
  }

  Future<List<ClientModel>> fetchClientItems({required bool isByPays}) async {
    try {
      final clients = await ClientService.getUnarchivedClients();

      final filteredClients = _selectedCountry != null
          ? clients
              .where((client) => client.pays?.code == _selectedCountry!.code)
              .toList()
          : clients;

      if (_selectedCountry != null && filteredClients.isEmpty && isByPays) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Aucun client dans ce pays.",
        );
      }

      return filteredClients;
    } catch (err) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: err.toString(),
      );

      setState(() {
        hasclient = false;
      });

      return [];
    }
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return (await BanqueService.getAllBanques()).where((banque) {
      return banque.country!.code == _selectedCountry!.code;
    }).toList();
  }

  Future<List<PaysModel>> fetchCountryItems() async {
    return await PaysService.getAllPays();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        //key: UniqueKey(),
        child: Column(
          children: [
            FutureCustomDropDownField<PaysModel>(
              label: "Pays",
              showSearchBox: true,
              selectedItem: _selectedCountry,
              fetchItems: fetchCountryItems,
              onChanged: (PaysModel? value) async {
                if (value != null) {
                  setState(() {
                    _selectedCountry = value;
                  });
                  final clientdata = await fetchClientItems(isByPays: true);
                  setState(() {
                    _selectedCountry = value;

                    client = null;
                    hasclient = clientdata.isNotEmpty;
                  });
                }
              },
              canClose: false,
              itemsAsString: (s) => s.name,
            ),
            if (hasclient == true) ...[
              CustomDropDownField<TypeFacture>(
                items: TypeFacture.values,
                label: "Type",
                onChanged: (value) {
                  setState(() {
                    type = value!;
                    if (type == TypeFacture.punctual) {
                      _dateDebutFacturation.text = "";
                      dateDebutFacturation = null;
                      _compterController.text = "";
                      unit == null;
                    }
                    if (type == TypeFacture.recurrent) {
                      _factureAcompteControllers.clear();
                    }
                  });
                },
                selectedItem: type,
                itemsAsString: (p0) => p0.label,
              ),
              FutureCustomDropDownField<ClientModel>(
                label: "Client",
                selectedItem: client,
                fetchItems: () {
                  return fetchClientItems(isByPays: false);
                },
                onChanged: (ClientModel? value) {
                  if (value != null) {
                    setState(() {
                      client = value;
                    });
                  }
                },
                itemsAsString: (c) => c.toStringify(),
              ),
              DateField(
                onCompleteDate: (value) {
                  setState(() {
                    dateEtablissement = value!;
                  });
                  _dateEtablissementController.text =
                      getStringDate(time: value!);
                },
                label: "Date d'établissement",
                lastDate: type == TypeFacture.recurrent
                    ? dateEnvoieFacture
                    : _factureAcompteControllers.isEmpty ||
                            _factureAcompteControllers
                                .first["dateEnvoieFacture"].text.isEmpty
                        ? DateTime.now()
                        : convertToDateTime(
                            _factureAcompteControllers
                                .first["dateEnvoieFacture"].text,
                          ),
                dateController: _dateEtablissementController,
                required: false,
              ),
              if (type == TypeFacture.recurrent) ...[
                DateField(
                  onCompleteDate: (value) {
                    setState(() {
                      dateEnvoieFacture = value!;
                    });
                    _dateEnvoieFacture.text = getStringDate(time: value!);
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
                futureItems: fetchBanqueItems().then((banks) => banks
                    .map((banque) => DropdownItem<BanqueModel>(
                          label: banque.name,
                          value: banque,
                        ))
                    .toList()),
                enableSearch: true,
                onSelectionChange: (p0) {
                  setState(() {
                    banques = p0;
                  });
                },
                hintText: 'Choisissez un ou plusieurs comptes',
                maxItems: 3,
                controller: _comptesController,
              ),
              if (type == TypeFacture.punctual) ...[
                FactureAcompteFields(
                  controllers: _factureAcompteControllers,
                  required: true,
                  dateEtablissement: dateEtablissement,
                ),
              ],
              if (type == TypeFacture.recurrent) ...[
                DateField(
                  onCompleteDate: (value) {
                    setState(() {
                      dateDebutFacturation = value!;
                    });
                    _dateDebutFacturation.text = getStringDate(time: value!);
                  },
                  firstDate: dateEtablissement,
                  label: "Date debut facturation",
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
                DurationField(
                  controller: _delaicompterController,
                  label: "Délai de payement",
                  onUnityChanged: (value) {
                    setState(() {
                      delaiUnit = value;
                    });
                  },
                  unitSelectItem: delaiUnit,
                ),
                // CustomRadioGroup(
                //   label: "Appliquer les règles de pénalité",
                //   groupValue: canPenalty,
                //   onChanged: (bool? value) {
                //     setState(() {
                //       tva = value!;
                //     });
                //   },
                //   defaultValue: true,
                // ),
              ],
              if (_selectedCountry != null)
                InitialLigneSpace(
                  controllers: _initialLignesControllers,
                  country: _selectedCountry!,
                  type: type,
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ValidateButton(
                      onPressed: addFacture,
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
