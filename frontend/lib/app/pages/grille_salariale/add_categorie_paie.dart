import 'package:flutter/material.dart';
import '../../../helper/string_helper.dart';
import '../../../service/categorie_paie_service.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'add_class_categorie_space.dart';

class AddCategoriePaiePage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddCategoriePaiePage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddCategoriePaiePage> createState() => _AddCategoriePaiePageState();
}

class _AddCategoriePaiePageState extends State<AddCategoriePaiePage> {
  final TextEditingController _libelleController = TextEditingController();

  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> _addCategoriePaie() async {
    String? errMessage;
    if (_libelleController.text.isEmpty) {
      errMessage = "Veuillez remplir tous les champs marqués.";
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

    var result = await CategoriePaieService.createCategoriePaie(
      categoriePaie:
          capitalizeFirstLetter(word: _libelleController.text.toLowerCase()),
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Catégorie de paie crée avec succès");
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
        AddClassCategorieSpace(),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: () async {
                await _addCategoriePaie();
              },
            ),
          ),
        ),
      ],
    );
  }
}
