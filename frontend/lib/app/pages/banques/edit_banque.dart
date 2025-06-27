import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/pays_model.dart';
import 'package:frontend/model/request_response.dart';
import 'package:frontend/service/banque_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../model/entreprise/type_canaux_paiement.dart';
import '../../../service/pays_service.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/file_field.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/telephone_field.dart';
import '../../../widget/validate_button.dart';

class EditBanquePage extends StatefulWidget {
  final VoidCallback refresh;
  final BanqueModel banque;

  const EditBanquePage({
    super.key,
    required this.refresh,
    required this.banque,
  });

  @override
  State<EditBanquePage> createState() => _EditBanquePageState();
}

class _EditBanquePageState extends State<EditBanquePage> {
  late TextEditingController _nomController;
  late TextEditingController _codeGuichetController;
  late TextEditingController _ribController;
  late TextEditingController _numCompteController;
  late TextEditingController _codeBICController;
  late TextEditingController _codeBanqueController;
  final TextEditingController _telephoneController = TextEditingController();
  PlatformFile? file;
  PlatformFile? initialFile;
  CanauxPaiement? type;
  late SimpleFontelicoProgressDialog _dialog;
  PaysModel? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);

    _selectedCountry = widget.banque.country;
    file = widget.banque.logo != null
        ? PlatformFile(
            name: widget.banque.logo!,
            size: 0,
          )
        : null;
    initialFile = widget.banque.logo != null
        ? PlatformFile(
            name: widget.banque.logo!,
            size: 0,
          )
        : null;
    _nomController = TextEditingController(text: widget.banque.name);
    type = widget.banque.type;
    _telephoneController.text = widget.banque.numCompte;
    _codeGuichetController =
        TextEditingController(text: widget.banque.codeGuichet);
    _ribController = TextEditingController(text: widget.banque.cleRIB);
    _numCompteController = TextEditingController(text: widget.banque.numCompte);
    _codeBICController = TextEditingController(text: widget.banque.codeBIC);
    _codeBanqueController =
        TextEditingController(text: widget.banque.codeBanque);
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
                      _numCompteController.clear();
                    }

                    if (type != CanauxPaiement.operateurMobile) {
                      _telephoneController.clear();
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
              ),
              SimpleTextField(
                label: "Code banque",
                textController: _codeBanqueController,
              ),
              SimpleTextField(
                label: "Numéro de compte",
                textController: _numCompteController,
              ),
              SimpleTextField(
                label: "Code BIC",
                textController: _codeBICController,
              ),
            ],
            if (type == CanauxPaiement.operateurMobile) ...[
              TelephoneTextField(
                label: "Téléphone",
                maxLength: _selectedCountry == null
                    ? 1
                    : _selectedCountry!.phoneNumber!,
                textController: _telephoneController,
                contryCode: _selectedCountry == null
                    ? ""
                    : _selectedCountry!.code.toString(),
              ),
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
                  onPressed: () => updateBanque(banque: widget.banque),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool hasChanges() {
    return widget.banque.cleRIB != _ribController.text.trim() ||
        widget.banque.numCompte != _numCompteController.text.trim() ||
        widget.banque.codeBIC != _codeBICController.text.trim() ||
        widget.banque.codeBanque != _codeBanqueController.text.trim() ||
        widget.banque.codeGuichet != _codeGuichetController.text.trim() ||
        widget.banque.name != _nomController.text.trim() ||
        initialFile != file ||
        file?.bytes != null ||
        type != widget.banque.type ||
        _selectedCountry != widget.banque.country;
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
      if (_numCompteController.text.trim().isEmpty) {
        return "Le numéro de compte est requis.";
      }
      if (_codeBICController.text.trim().isEmpty) {
        return "Le code BIC est requis.";
      }
    }

    if (type == CanauxPaiement.operateurMobile) {
      if (_telephoneController.text.trim().isEmpty) {
        return "Le numéro de téléphone est requis.";
      }
      if (_telephoneController.text.trim().length !=
          (_selectedCountry?.phoneNumber ?? 8)) {
        return "Le numéro de téléphone doit comporter ${_selectedCountry?.phoneNumber ?? 8} chiffres.";
      }
    }

    return null; // OK
  }

  Future<void> updateBanque({required BanqueModel banque}) async {
    final error = validateInputs();
    if (error != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: error);
      return;
    }

    if (!hasChanges()) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Aucune modification n'a été apportée!",
      );
      return;
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    RequestResponse result = await BanqueService.updateBanque(
      key: banque.id,
      cleRIB: _ribController.text.trim().isEmpty
          ? null
          : _ribController.text.trim(),
      codeBIC: _codeBICController.text.trim().isEmpty
          ? null
          : _codeBICController.text.trim(),
      type: type,
      numCompte: type == CanauxPaiement.operateurMobile
          ? (_telephoneController.text.trim().isNotEmpty
              ? _telephoneController.text.trim()
              : null)
          : (_numCompteController.text.trim().isNotEmpty
              ? _numCompteController.text.trim()
              : null),
      codeBanque: _codeBanqueController.text.trim().isEmpty
          ? null
          : _codeBanqueController.text.trim(),
      codeGuichet: _codeGuichetController.text.trim().isEmpty
          ? null
          : _codeGuichetController.text.trim(),
      file: file,
      name: _nomController.text.trim(),
      country: _selectedCountry,
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage:
            "Canal de paiement ${banque.name} a été mise à jour avec succès!",
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
