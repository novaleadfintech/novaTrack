import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/entreprise/banque.dart';
import '../../../../model/facturation/facture_acompte.dart';
import '../../../../service/banque_service.dart';
import '../../../../service/proforma_service.dart';
import '../../../../style/app_color.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../model/request_response.dart';
import '../../../../widget/date_text_field.dart';
import '../../../../widget/facture_acompte_fields.dart';
import '../../../../widget/multiple_select_drop_down.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';

class ValidateProformatPage extends StatefulWidget {
  final String proformaId;
  final Future<void> Function() refresh;
  const ValidateProformatPage({
    super.key,
    required this.refresh,
    required this.proformaId,
  });

  @override
  State<ValidateProformatPage> createState() => _ValidateProformatPageState();
}

class _ValidateProformatPageState extends State<ValidateProformatPage> {
  DateTime? dateEtablissement;
  final TextEditingController _dateEtablissementController =
      TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;
  final List<Map<String, dynamic>> _factureAcompteControllers = [];
  final MultiSelectController<BanqueModel> _comptesController =
      MultiSelectController<BanqueModel>();
  List<BanqueModel>? banques;

  validateProforma({required String proformaId}) async {
    if (_factureAcompteControllers.isEmpty || banques == null) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage: "Veuillez remplir tous les champs",
      );
      return;
    }
    /*  bool hasEmptyFields = _factureAcompteControllers
        .any((element) => element["pourcentage"] || element["montant"]);

    if (hasEmptyFields) {
      return "Veuillez remplir tous les champs pour chaque acompte.";
    } */

    for (var toElement in _factureAcompteControllers) {
      var pourcentageController = toElement["pourcentage"];
      var dateController = toElement["dateEnvoieFacture"];

      if (pourcentageController == null ||
          pourcentageController.text.isEmpty ||
          int.tryParse(pourcentageController.text) == null) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.customError,
          customMessage: "Veuillez remplir tous les champs du pourcentage.",
        );
        return;
      }

      if (dateController == null || dateController.text.isEmpty) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.customError,
          customMessage: "Veuillez renseigner une date d'envoi valide.",
        );
        return;
      }
    }

    int sommePourcentage = _factureAcompteControllers.fold(
        0, (somme, element) => somme + int.parse(element["pourcentage"].text));
    if (sommePourcentage != 100) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage:
            "Revoyez la repartition des pourcentage sur des factures d'accompte. La somme doit etre impérativement 100",
      );
      return;
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
      indicatorColor: AppColor.primaryColor,
    );

    try {
      RequestResponse result = await ProformaService.validerProforma(
          proformaId: proformaId,
          dateEtablissementFacture: dateEtablissement,
          banques: banques!,
          facturesAcompte: _factureAcompteControllers
              .map(
                (factureAcompte) => FactureAcompteModel(
                    rang: int.parse(factureAcompte["rang"].text),
                    pourcentage: int.parse(factureAcompte["pourcentage"].text),
                  canPenalty: factureAcompte["canPenalty"],
                    dateEnvoieFacture: convertToDateTime(
                        factureAcompte["dateEnvoieFacture"].text),
                  isPaid: false,
                ),
              )
              .toList());

      _dialog.hide();
      MutationRequestContextualBehavior.closePopup();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: "Proforma validé avec succès.",
        );
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: e.toString(),
      );
    }
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return await BanqueService.getAllBanques();
  }

  @override
  void initState() {
    dateEtablissement = DateTime.now();
    _dateEtablissementController.text = getStringDate(time: dateEtablissement!);
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DateField(
            onCompleteDate: (value) {
              setState(() {
                dateEtablissement = value!;
              });
              _dateEtablissementController.text = getStringDate(time: value!);
            },
            lastDate: (_factureAcompteControllers.isEmpty ||
                    _factureAcompteControllers
                        .first["dateEnvoieFacture"].text.isEmpty)
                ? DateTime.now()
                : convertToDateTime(
                    _factureAcompteControllers.first["dateEnvoieFacture"].text,
                  ).isAfter(DateTime.now())
                    ? DateTime.now()
                    : convertToDateTime(
                        _factureAcompteControllers
                            .first["dateEnvoieFacture"].text,
                      ),
            label: "Date d'établissement",
            dateController: _dateEtablissementController,
            required: false,
          ),
          DefaultMultipleDropdownField<BanqueModel>(
            labelText: 'Comptes de payements',
            futureItems: fetchBanqueItems().then((banques) => banques
                .map((banque) => DropdownItem<BanqueModel>(
                      label: banque.name,
                      value: banque,
                    ))
                .toList()),
            enableSearch: true,
            onSelectionChange: (p0) => {
              setState(() {
                banques = p0;
              })
            },
            hintText: 'Choisissez un ou plusieurs comptes',
            maxItems: 3,
            controller: _comptesController,
          ),
          FactureAcompteFields(
            controllers: _factureAcompteControllers,
            dateEtablissement: dateEtablissement,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ValidateButton(
                  onPressed: () => validateProforma(
                    proformaId: widget.proformaId,
                  ),
                  libelle: "Suivant",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
