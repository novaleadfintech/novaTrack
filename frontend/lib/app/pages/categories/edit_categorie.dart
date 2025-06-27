import 'package:flutter/material.dart';
import 'package:frontend/model/client/categorie_model.dart';
import '../../../helper/string_helper.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../service/categorie_service.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class EditCategoriePage extends StatefulWidget {
  final Future<void> Function() refresh;
  final CategorieModel categorie;
  const EditCategoriePage({
    super.key,
    required this.refresh,
    required this.categorie,
  });

  @override
  State<EditCategoriePage> createState() => _EditCategoriePageState();
}

class _EditCategoriePageState extends State<EditCategoriePage> {
  final TextEditingController _libelleController = TextEditingController();

  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _libelleController.text = widget.categorie.libelle;
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> _editCategorie() async {
    String? errMessage;
    if (_libelleController.text.isEmpty) {
      errMessage = "Veuillez remplir tous les champs marqués.";
    }

    if (_libelleController.text == widget.categorie.libelle) {
      errMessage = "Veuillez modifier le libellé.";
    }
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

    var result = await CategorieService.createCategorie(
      libelle: capitalizeFirstLetter(word: _libelleController.text.toLowerCase()),
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Catégorie modifié avec succès");
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleTextField(
          label: "Libellé",
          textController: _libelleController,
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: () async {
                await _editCategorie();
              },
            ),
          ),
        ),
      ],
    );
  }
}
