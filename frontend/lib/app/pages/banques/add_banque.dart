import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/model/pays_model.dart';
import "package:frontend/model/request_response.dart";
import '../../../service/banque_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/entreprise/type_canaux_paiement.dart';
import '../../../service/pays_service.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/file_field.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';

class AddBanquePage extends StatefulWidget {
  final VoidCallback refresh;
  const AddBanquePage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddBanquePage> createState() => _AddBanquePageState();
}

class _AddBanquePageState extends State<AddBanquePage> {
  late SimpleFontelicoProgressDialog _dialog;

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _codeGuichetController = TextEditingController();
  final TextEditingController _ribController = TextEditingController();
  final TextEditingController _codeBanqueController = TextEditingController();
  final TextEditingController _codeBICController = TextEditingController();
  final TextEditingController _numBanqueController = TextEditingController();
  PlatformFile? file;
  CanauxPaiement? type;

  PaysModel? _selectedCountry;
  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);

    super.initState();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SimpleTextField(
              label: "Nom",
              textController: _nomController,
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
            CustomDropDownField<CanauxPaiement>(
              items: CanauxPaiement.values.map((e) => e).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                    if (type != CanauxPaiement.banque) {
                      _codeBICController.clear();
                      _codeBanqueController.clear();
                      _codeGuichetController.clear();
                      _ribController.clear();
                      _numBanqueController.clear();
                    }
                  });
                }
              },
              itemsAsString: (p0) => p0.label,
              selectedItem: type,
              label: "Type",
            ),
            if (type == CanauxPaiement.banque) ...[
              SimpleTextField(
                label: "Code guichet",
                textController: _codeGuichetController,
              ),
              SimpleTextField(
                label: "RIB",
                textController: _ribController,
                //maxlength: 2,
              ),
              SimpleTextField(
                label: "Code banque",
                textController: _codeBanqueController,
              ),
              SimpleTextField(
                label: "Numéro de compte",
                textController: _numBanqueController,
                //maxlength: 2,
              ),
              SimpleTextField(
                label: "Code BIC",
                textController: _codeBICController,
              ),
              // SimpleTextField(
              //   label: "Solde initial",
              //   textController: _montantController,
              //   keyboardType: TextInputType.number,
              //   inputFormaters: [
              //     FilteringTextInputFormatter.digitsOnly,
              //   ],
              // ),
            ],
            if (type == CanauxPaiement.operateurMobile) ...[
              SimpleTextField(
                label: "Numéro de compte",
                textController: _numBanqueController,
                //maxlength: 2,
              ),
              // TelephoneTextField(
              //   label: "Téléphone",
              //   maxLength: _selectedCountry == null
              //       ? 1
              //       : _selectedCountry!.phoneNumber!,
              //   textController: _telephoneController,
              //   contryCode: _selectedCountry == null
              //       ? ""
              //       : _selectedCountry!.code.toString(),
              // ),
            ],
            if (type != CanauxPaiement.caisse) ...[
              FileField(
                canTakePhoto: false,
                required: false,
                label: "Logo",
                platformFile: file,
                removeFile: () => setState(() {
                  file = null;
                }),
                pickFile: (p0) {
                  setState(() {
                    file = p0;
                  });
                },
              ),
            ],
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () {
                    addBanque();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validateInputs() {
    if (_nomController.text.trim().isEmpty) {
      return "Le nom est requis.";
    }

    if (_selectedCountry == null) {
      return "Le pays est requis.";
    }

    if (type == null) {
      return "Le type de canal est requis.";
    }

    if (type == CanauxPaiement.banque) {
      if (_codeGuichetController.text.trim().isEmpty) {
        return "Le code guichet est requis.";
      }
      if (_ribController.text.trim().isEmpty) return "Le RIB est requis.";
      if (_ribController.text.trim().length != 2) {
        return "Le RIB doit comporter exactement 2 caractères.";
      }
      if (_codeBanqueController.text.trim().isEmpty) {
        return "Le code banque est requis.";
      }
      if (_numBanqueController.text.trim().isEmpty) {
        return "Le numéro de compte est requis.";
      }
      if (_codeBICController.text.trim().isEmpty) {
        return "Le code BIC est requis.";
      }
    }

    if (type == CanauxPaiement.operateurMobile) {
      if (_numBanqueController.text.trim().isEmpty) {
        return "Le numéro de compte est requis.";
      }
    }

    return null; // OK
  }

  void addBanque() async {
    final error = validateInputs();
    if (error != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: error,
      );
      return;
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    RequestResponse result = await BanqueService.createBanque(
      name: _nomController.text.trim(),
      type: type!,
      codeBanque: _codeBanqueController.text.trim(),
      codeBIC: _codeBICController.text.trim(),
      numCompte: _numBanqueController.text.trim(),
      codeGuichet: _codeGuichetController.text.trim(),
      country: _selectedCountry!,
      cleRIB: _ribController.text.trim(),
      file: file,
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: "Compte créé avec succès!",
      );
      widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }
  
}
