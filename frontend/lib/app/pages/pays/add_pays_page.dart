import 'package:country/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/service/pays_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../global/constant/request_management_value.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';

class AddPaysPage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddPaysPage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddPaysPage> createState() => _AddPaysPageState();
}

class _AddPaysPageState extends State<AddPaysPage> {
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
  }

  Future<void> addPays() async {
    try {
      final nom = _nomController.text.trim();
      String errorMessage = "";
      final taux = _tauxtvaController.text.trim();
      final code =
          int.tryParse(_codeController.text.trim()); // Utiliser tryParse() ici
      final nbrePhoneTel =
          int.tryParse(_phoneNumberCaracterController.text.trim());

      // Vérification des champs nécessaires
      if (_selectedCountry == null ||
          taux.isEmpty ||
          code == null ||
          (nbrePhoneTel != null && nbrePhoneTel == 0) ||
          _debutNumTelCotroller.text.isEmpty) {
        errorMessage = "Veuillez remplir les champs marqués";
      }

      // Validation du taux de TVA
      if (taux.isNotEmpty &&
          double.tryParse(taux) != null &&
          double.parse(taux) > 100) {
        errorMessage = "Le taux doit être inférieur à 100";
      }

      // Si un message d'erreur existe, l'afficher et sortir de la méthode
      if (errorMessage.isNotEmpty) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: errorMessage,
        );
        return;
      }

      // Affichage du dialogue de chargement
      _dialog.show(
        message: RequestMessage.loadinMessage,
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      // Appel au service de création de pays
      var result = await PaysService.createPays(
        nom: nom,
        taux: double.parse(taux),
        nbreNumTel:
            nbrePhoneTel ?? 0, // Assure que nbrePhoneTel n'est jamais null
        initiauxPays: _debutNumTelCotroller.text
            .trim()
            .split(" ")
            .map((str) =>
                int.tryParse(str) ??
                0)
            .toList(),
        code: code!,
      );

      // Fermeture du dialogue de chargement
      _dialog.hide();

      // Affichage du résultat du processus de création
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Pays créé avec succès",
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
                    addPays();
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
