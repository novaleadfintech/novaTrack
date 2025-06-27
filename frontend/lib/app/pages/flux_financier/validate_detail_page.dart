import 'package:flutter/material.dart';
import 'package:frontend/app/pages/flux_financier/detail_flux.dart';
import 'package:frontend/model/flux_financier/type_flux_financier.dart';
import 'package:frontend/model/flux_financier/validate_flux_model.dart';
import 'package:frontend/service/flux_financier_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../model/request_response.dart';
import '../../../widget/simple_text_field.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class ValidateDetailPage extends StatefulWidget {
  final VoidCallback refresh;
  final FluxFinancierModel flux;
  const ValidateDetailPage({
    super.key,
    required this.flux,
    required this.refresh,
  });

  @override
  State<ValidateDetailPage> createState() => _ValidateDetailPageState();
}

class _ValidateDetailPageState extends State<ValidateDetailPage> {
  FluxFinancierStatus? selectedValue;
  final TextEditingController _commentaireController = TextEditingController();
  UserModel? user;
  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    initData();
  }

  void initData() async {
    user = await AuthService().decodeToken();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DetailFluxPage(flux: widget.flux),
          Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.2),
            ),
            child: widget.flux.user!.equalTo(user: user!)
                ? Text(
                    'Vous avez saisi ce flux financier, vous ne pouvez donc plus le valider',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quel est votre décision suite à la vérification de ce flux financier ?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...FluxFinancierStatus.values.map(
                        (status) => Row(
                          children: [
                            Radio<FluxFinancierStatus>(
                              value: status,
                              groupValue: selectedValue,
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value!;
                                  _commentaireController.clear();
                                });
                              },
                            ),
                            Text(status.label),
                          ],
                        ),
                      ),
                      if (selectedValue != null)
                        SimpleTextField(
                          label: "Justifiez votre choix",
                          textController: _commentaireController,
                          expands: true,
                          maxLines: null,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 80,
                        ),
                    ],
                  ),
          ),
          if (selectedValue != null &&
              !widget.flux.user!.equalTo(user: user!)) ...[
            Gap(16),
            ElevatedButton(
              onPressed: () {
                onValidate();
              },
              child: const Text("Soumettre"),
            ),
          ]
        ],
      ),
    );
  }

  late SimpleFontelicoProgressDialog _dialog;
  void onValidate() async {
    try {
      if (selectedValue == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Vous avez oublié de donnez votre avis, SVP.",
      );
      return;
    }
    if (_commentaireController.text.trim().isEmpty) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez justifier votre choix, SVP.",
      );
      return;
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    RequestResponse response = await FluxFinancierService.validateFluxFinancier(
      key: widget.flux.id,
      validateFlux: ValidateFluxModel(
          validateStatus: selectedValue!,
        date: DateTime.now(),
        validater: user!,
        commentaire: _commentaireController.text.trim(),
      ),
    );
    _dialog.hide();
    if (response.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: response.status,
        customMessage: "Opération réussie",
      );
      widget.refresh();
      return;
    } else {
        _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: response.status,
        customMessage: response.message,
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
}
