import 'package:flutter/material.dart';
import '../../../helper/string_helper.dart';
import '../../../model/bulletin_paie/categorie_paie.dart';
import '../../../service/categorie_paie_service.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class EditCategoriePaiePage extends StatefulWidget {
  final Future<void> Function() refresh;
  final CategoriePaieModel categorie;
  const EditCategoriePaiePage({
    super.key,
    required this.refresh,
    required this.categorie,
  });

  @override
  State<EditCategoriePaiePage> createState() => _EditCategoriePaiePageState();
}

class _EditCategoriePaiePageState extends State<EditCategoriePaiePage> {
  final TextEditingController _libelleController = TextEditingController();

  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _libelleController.text = widget.categorie.categoriePaie;
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> _editCategoriePaie() async {
    String? errMessage;
    if (_libelleController.text.isEmpty) {
      errMessage = "Veuillez remplir tous les champs marqués.";
    }

    if (_libelleController.text == widget.categorie.categoriePaie) {
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

    try {
      var result = await CategoriePaieService.upadateCategoriePaie(
        categoriePaie:
            capitalizeFirstLetter(word: _libelleController.text.toLowerCase()),
        key: widget.categorie.id,
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
    } catch (err) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: err.toString(),
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
                await _editCategoriePaie();
              },
            ),
          ),
        ),
      ],
    );
  }
}
