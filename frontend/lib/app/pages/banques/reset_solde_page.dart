import 'package:flutter/material.dart';
 import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/request_response.dart';
import 'package:frontend/service/banque_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';

class ResetSoldePage extends StatefulWidget {
  final VoidCallback refresh;
  final BanqueModel banque;
  const ResetSoldePage({
    super.key,
    required this.refresh,
    required this.banque,
  });

  @override
  State<ResetSoldePage> createState() => _ResetSoldePageState();
}

class _ResetSoldePageState extends State<ResetSoldePage> {
  final TextEditingController _amountController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleTextField(
          label: "Montant actuel",
          textController: _amountController,
          keyboardType: TextInputType.number,
          
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              libelle: "Valider",
              onPressed: () async {
                await resetBanqueSolde(
                  banque: widget.banque,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  resetBanqueSolde({
    required BanqueModel banque,
  }) async {
    if (_amountController.text.isEmpty) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir le champs",
      );
      return;
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    RequestResponse result = await BanqueService.resetBanqueAmount(
      key: banque.id,
      somme: double.parse(
        _amountController.text,
      ),
    );
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: "Solde de ${banque.name} est réinitialisé avec succès!",
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
