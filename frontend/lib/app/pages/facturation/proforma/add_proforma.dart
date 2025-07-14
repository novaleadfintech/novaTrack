import 'package:flutter/material.dart';
import 'package:frontend/dto/facturation/ligne_dto.dart';
import 'package:frontend/model/facturation/enum_facture.dart';
import '../../../../model/pays_model.dart';
import '../../../../service/pays_service.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/client/client_model.dart';
import '../../../../model/service/service_model.dart';
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
import '../initial_ligne_space.dart';

class AddFactureProformat extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddFactureProformat({
    super.key,
    required this.refresh,
  });

  @override
  State<AddFactureProformat> createState() => _AddFactureProformatState();
}

class _AddFactureProformatState extends State<AddFactureProformat> {
  final TextEditingController _dateEtablissementController =
      TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;

  final TextEditingController _dateEnvoieController = TextEditingController();
  final TextEditingController _compterController = TextEditingController();
  final List<LigneDto> _initialLignesControllers = [];
  ClientModel? client;
  ServiceModel? service;
  late DateTime? dateEtablissement;
  DateTime? dateEnvoie;
  bool tva = false;
  PaysModel? _selectedCountry;
  String? unit;
  int? garantyPeriode;
  bool hasClient = false;

  String? validateFields() {
    if (client == null ||
        _dateEnvoieController.text.isEmpty ||
        _dateEtablissementController.text.isEmpty ||
        _initialLignesControllers.isEmpty) {
      return "Veillez remplir tous les champ marqués";
    }
    bool isGarantieFilled = unit != null && _compterController.text.isNotEmpty;
    if (isGarantieFilled) {
      garantyPeriode =
          int.parse(_compterController.text) * unitMultipliers[unit]!;
    } else {
      return "Veuillez remplir les deux champs de garantie (unité et compteur).";
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    dateEtablissement = DateTime.now();
    _dateEtablissementController.text = getStringDate(time: dateEtablissement!);
  }

  addProformat() async {
    String? errMessage = validateFields();

    if (errMessage != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errMessage,
      );
      return;
    }

    RequestResponse result = await ProformaService.createProformat(
      clientId: client!.id,
      tva: tva,
      dateEnvoie: dateEnvoie!,
      dateEtablissementProforma: dateEtablissement,
      garantie: garantyPeriode!,
      lignes: _initialLignesControllers,
    );
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Proforma enrégistré avec succès",
      );
      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }

  Future<List<ClientModel>> fetchClientItems(
      {required bool isCheckedByPays}) async {
    List<ClientModel> clients =
        await ClientService.getUnarchivedClientsAndProspects();
    if (_selectedCountry != null) {
      clients = clients
          .where((client) => client.pays?.code == _selectedCountry!.code)
          .toList();
      if (clients.isEmpty && isCheckedByPays) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Aucun client dans ce pays.",
        );
      }
    }
    return clients;
  }

  @override
  void dispose() {
    _dateEtablissementController.dispose();
    _dateEnvoieController.dispose();
    _compterController.dispose();
    super.dispose();
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
                  final clientdata =
                      await fetchClientItems(isCheckedByPays: true);
                  setState(() {
                    _selectedCountry = value;

                    client = null;
                    hasClient = clientdata.isNotEmpty;
                  });
                }
              },
              canClose: false,
              itemsAsString: (s) => s.name,
            ),
            if (hasClient == true) ...[
              FutureCustomDropDownField<ClientModel>(
                label: "Client",
                selectedItem: client,
                fetchItems: () {
                  return fetchClientItems(isCheckedByPays: false);
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
                    if (value != null) {
                      dateEtablissement = value;
                      _dateEtablissementController.text =
                          getStringDate(time: value);
                    }
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
                    if (value != null) {
                      tva = value;
                    }
                  });
                },
                defaultValue: false,
              ),

              /*  const DefaultMultipleDropdownField<Banque>(
              labelText: "Lieu de payement",
              items: [],
            ), */
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
                    if (value != null) {
                      dateEnvoie = value;
                      _dateEnvoieController.text = getStringDate(time: value);
                    }
                  });
                },
                firstDate: dateEtablissement,
                label: "Date d'envoi",
                dateController: _dateEnvoieController,
              ),
              if (_selectedCountry != null)
                InitialLigneSpace(
                  controllers: _initialLignesControllers,
                  country: _selectedCountry!,
                  type: TypeFacture.punctual,
                ),
              const Gap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ValidateButton(onPressed: addProformat),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
