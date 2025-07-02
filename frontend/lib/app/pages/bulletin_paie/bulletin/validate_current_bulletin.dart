import 'package:flutter/material.dart';
import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/app/pages/bulletin_paie/detail_bulletin.dart';
import 'package:frontend/model/bulletin_paie/bulletin_model.dart';
import 'package:frontend/model/bulletin_paie/validate_bulletin_model.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/habilitation/user_model.dart';
import 'package:frontend/service/banque_service.dart';
import 'package:frontend/service/bulletin_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/bulletin_paie/etat_bulletin.dart';
import '../../../../model/request_response.dart';
import '../../../../widget/confirmation_dialog_box.dart';
import '../../../../widget/date_text_field.dart';
import '../../../../widget/enum_selector_radio.dart';
import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';

class ValidateCurrentBulletintPage extends StatefulWidget {
  final VoidCallback refresh;
  final BulletinPaieModel currentBulletin;
  const ValidateCurrentBulletintPage({
    super.key,
    required this.refresh,
    required this.currentBulletin,
  });

  @override
  State<ValidateCurrentBulletintPage> createState() =>
      _ValidateCurrentBulletintPageState();
}

class _ValidateCurrentBulletintPageState
    extends State<ValidateCurrentBulletintPage> {
  late SimpleFontelicoProgressDialog _dialog;
  UserModel? user;
  EtatBulletin? etatBulletin;
  final TextEditingController _datePayementController = TextEditingController();
  final TextEditingController _commentaireController = TextEditingController();
  DateTime? datePayement;
  Future<List<BanqueModel>> fetchItems() async {
    return await BanqueService.getAllBanques();
  }

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    initData();
    super.initState();
  }

  void initData() async {
    user = await AuthService().decodeToken();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DetailBulletinPage(bulletin: widget.currentBulletin),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withOpacity(0.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quel est votre décision suite à la vérification des données de bulletin ?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              EnumRadioSelector<EtatBulletin>(
                title: "Sélectionnez un type",
                selectedValue: etatBulletin,
                values: EtatBulletin.values,
                getLabel: (value) => value.label,
                onChanged: (value) {
                  setState(() {
                    etatBulletin = value;
                  });
                },
                isRequired: true,
              ),
              if (etatBulletin != null)
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
        if (etatBulletin == EtatBulletin.valid)
          DateField(
            firstDate: widget.currentBulletin.dateEdition,
          onCompleteDate: (value) {
            setState(() {
              datePayement = value!;
              _datePayementController.text = getStringDate(time: value);
            });
          },
            label: "Date de paiement",
          dateController: _datePayementController,
          ), 
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: () async {
                await _validate();
              },
            ),
          ),
        ),
      ],
    );
  }

  _validate() async {
    try {
      if (etatBulletin == null) {
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
      if (datePayement == null) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Veuillez renseigner la date de paiement, SVP.",
        );
        return;
      }
      bool confirmed = await handleOperationButtonPress(
        context,
        content:
            "Voulez-vous vraiment ${etatBulletin == EtatBulletin.wait ? "mettre ${etatBulletin!.label.toLowerCase()}" : etatBulletin!.label.toLowerCase()} ce bulletin de paie?",
      );

      if (!confirmed) {
        return;
      }
      _dialog.show(
        message: "",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse response = await BulletinService.validerBulletin(
        key: widget.currentBulletin.id,
        datePayement: datePayement,
        validateBulletin: ValidateBulletinModel(
          validateStatus: etatBulletin!,
          date: DateTime.now(),
          validater: user!,
          commentaire: _commentaireController.text,
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
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        customMessage: e.toString(),
        status: PopupStatus.serverError,
      );
    }
  }
}
