import 'package:country/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/service/pays_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../global/constant/request_management_value.dart';
import '../../../model/pays_model.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';

class EditPaysPage extends StatefulWidget {
  final PaysModel pays;
  final Future<void> Function() refresh;
  const EditPaysPage({
    super.key,
    required this.pays,
    required this.refresh,
  });

  @override
  State<EditPaysPage> createState() => _EditPaysPageState();
}

class _EditPaysPageState extends State<EditPaysPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _tauxtvaController = TextEditingController();
  final TextEditingController _debutNumTelCotroller = TextEditingController();
  final TextEditingController _phoneNumberCaracterController =
      TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Country? _selectedCountry;
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _nomController.text = widget.pays.name;
    _debutNumTelCotroller.text = widget.pays.initiauxPays.join(" ");
    _selectedCountry = Countries.values.firstWhere((country) =>
        country.countryCode == widget.pays.code.toString() &&
        (country.isoShortNameByLocale["fr"] == widget.pays.name ||
            country.isoShortName == widget.pays.name));
    _tauxtvaController.text = widget.pays.tauxTVA.toString();
    _phoneNumberCaracterController.text = widget.pays.phoneNumber.toString();
    _codeController.text = widget.pays.code.toString();
  }

  Future<void> editPays() async {
    final nom = _nomController.text.trim();
    String errorMessage = "";
    final taux = _tauxtvaController.text.trim();
    final code = int.parse(_codeController.text.trim());
    final nbrePhoneTel = int.parse(_phoneNumberCaracterController.text.trim());

    if (_selectedCountry == null ||
        taux.isEmpty ||
        _debutNumTelCotroller.text.isEmpty) {
      errorMessage = "Veuillez remplir les champs marqués";
    }

    if (double.parse(_tauxtvaController.text) > 100) {
      errorMessage = "Le taux doit être inférieur à 100";
    }
    if (_selectedCountry!.countryCode == widget.pays.code.toString() &&
        taux == widget.pays.tauxTVA.toString() &&
        nbrePhoneTel == widget.pays.phoneNumber &&
        _debutNumTelCotroller.text == widget.pays.initiauxPays.join(" ")) {
      errorMessage = "Aucune modification n'a été apportée";
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
    var result = await PaysService.updatePays(
      paysId: widget.pays.id!,
      nom: nom,
      taux: double.parse(taux),
      nbreNumTel: nbrePhoneTel,
      initiauxPays: _debutNumTelCotroller.text
          .trim()
          .split(" ")
          .map((str) => int.parse(str))
          .toList(),  
      code: code,
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Pays mis à jour avec succès",
      );
      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: UniqueKey(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropDownField<Country>(
              items: Countries.values,
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country;
                  _nomController.text =
                      _selectedCountry!.isoShortNameByLocale.containsKey("fr")
                          ? _selectedCountry!.isoShortNameByLocale["fr"]!
                          : _selectedCountry!.isoShortName;
                  _codeController.text = _selectedCountry!.countryCode;
                  _phoneNumberCaracterController.text =
                      (_selectedCountry!.nationalNumberLengths.last + 1)
                          .toString();
                });
              },
              selectedItem: _selectedCountry,
              itemsAsString: (country) =>
                  country.isoShortNameByLocale.containsKey("fr")
                      ? country.isoShortNameByLocale["fr"]!
                      : country.isoShortName,
              filter: true,
              label: "Pays",
            ),
            SimpleTextField(
              label: "Nom",
              readOnly: true,
              textController: _nomController,
            ),
            SimpleTextField(
              label: "Indicatif",
              textController: _codeController,
              keyboardType: TextInputType.number,
              readOnly: true,
            ),
            SimpleTextField(
              label: "Nombre de chiffres du téléphone",
              textController: _phoneNumberCaracterController,
              keyboardType: TextInputType.number,
              readOnly: false,
              required: true,
            ),
            SimpleTextField(
              label: "Taux TVA (%)",
              textController: _tauxtvaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              required: true,
            ),
            SimpleTextField(
              label:
                  "Les différents début de numéro telephonique (Ex : 98 78)", // les debuts des numéro télephonique 99 67 87
              textController: _debutNumTelCotroller,
              keyboardType: TextInputType.text,
              inputFormaters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^[\d\s?]*$'),
                )
              ],
              required: true,
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () {
                    editPays();
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
