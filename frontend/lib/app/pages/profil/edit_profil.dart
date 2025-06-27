import 'package:flutter/material.dart';
import 'package:frontend/service/role_service.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../helper/string_helper.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import 'package:gap/gap.dart';

import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class EditProfil extends StatefulWidget {
  final Future<void> Function() refresh;
  final RoleModel profil;

  const EditProfil({super.key, required this.refresh, required this.profil});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  final _profilController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _profilController.text = widget.profil.libelle;
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  editProfil() async {
    String? errMessage;
    if (_profilController.text.isEmpty) {
      errMessage = "Veuillez remplir tous les champs marqués.";
    }
    if (_profilController.text == widget.profil.libelle) {
      errMessage = "Aucune modification n'est faite";
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

    var result = await RoleService.updateRole(
      key: widget.profil.id!,
      libelle:
          capitalizeFirstLetter(word: _profilController.text.toLowerCase()),
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Role modifié avec succès",
      );
      widget.refresh();
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
      children: [
        SimpleTextField(label: "Libelle", textController: _profilController),
        const Gap(8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: () {
                editProfil();
              },
            ),
          ),
        )
      ],
    );
  }
}
