import 'package:flutter/material.dart';
 import 'package:frontend/model/commentaire_model.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/facturation/facture_acompte.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../model/habilitation/user_model.dart';
import '../../../../model/request_response.dart';
import '../../../../service/facture_service.dart';
import '../../../../widget/custom_radio_yer_or_no.dart';
import '../../../../widget/date_text_field.dart';
import '../../../../widget/duration_field.dart';
import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';

class EditFactureAccompte extends StatefulWidget {
  final FactureAcompteModel factureAcompte;
  final DateTime dateEtablissement;
  final String factureId;
  final RoleModel role;  
  final VoidCallback refresh;
  const EditFactureAccompte({
    super.key,
    required this.factureId,
    required this.refresh,
    required this.role,
    required this.dateEtablissement,
    required this.factureAcompte,
  });

  @override
  State<EditFactureAccompte> createState() => _EditFactureAccompteState();
}

class _EditFactureAccompteState extends State<EditFactureAccompte> {
  final TextEditingController _dateEnvoieFactureController =
      TextEditingController();
  final TextEditingController _dateEcheanteController = TextEditingController();
  final TextEditingController _rangController = TextEditingController();
  final TextEditingController _commentaireController = TextEditingController();
  final TextEditingController _pourcentageController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;

  late DateTime dateEnvoieFacture;
  DateTime? newDateEnvoieFacture;
  late DateTime? dateEcheantePayement;
  DateTime? newDateEcheantePayement;
  late bool canPenalty;
  UserModel? user;
  String? unit;
  final TextEditingController _compterController = TextEditingController();
  late String initialUnit;
  late String initCompter;
  // Future<void> _selectDate(
  //   BuildContext context,
  //   TextEditingController controller,
  // ) async {
  //   DateTime initialDate = widget.factureAcompte.dateEnvoieFacture;

  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate:
  //         initialDate.isAfter(DateTime.now()) ? initialDate : DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2100),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       dateEnvoieFacture = picked;
  //       controller.text = getStringDate(time: picked);
  //     });
  //   }
  // }

  @override
  void initState() {
    _compterController.addListener(() {
      setState(() {});
    });
    dateEnvoieFacture = widget.factureAcompte.dateEnvoieFacture;
    canPenalty = widget.factureAcompte.canPenalty;
    _dateEnvoieFactureController.text = getStringDate(time: dateEnvoieFacture);

    _dateEcheanteController.text =
        widget.factureAcompte.datePayementEcheante == null
            ? ""
            : getStringDate(time: widget.factureAcompte.datePayementEcheante!);
    _compterController.text = widget.factureAcompte.datePayementEcheante != null
        ? convertDuration(
            durationMs: (widget.factureAcompte.datePayementEcheante!
                    .millisecondsSinceEpoch -
                widget.factureAcompte.dateEnvoieFacture.millisecondsSinceEpoch),
          ).compteur.toString()
        : "";
    unit = widget.factureAcompte.datePayementEcheante != null
        ? convertDuration(
            durationMs: widget.factureAcompte.datePayementEcheante!
                    .millisecondsSinceEpoch -
                widget.factureAcompte.dateEnvoieFacture.millisecondsSinceEpoch,
          ).unite
        : "";
    initCompter = widget.factureAcompte.datePayementEcheante != null
        ? convertDuration(
            durationMs: (widget.factureAcompte.datePayementEcheante!
                    .millisecondsSinceEpoch -
                widget.factureAcompte.dateEnvoieFacture.millisecondsSinceEpoch),
          ).compteur.toString()
        : "";
    initialUnit = widget.factureAcompte.datePayementEcheante != null
        ? convertDuration(
            durationMs: widget.factureAcompte.datePayementEcheante!
                    .millisecondsSinceEpoch -
                widget.factureAcompte.dateEnvoieFacture.millisecondsSinceEpoch,
          ).unite
        : "";
    dateEcheantePayement = widget.factureAcompte.datePayementEcheante;
    _rangController.text = widget.factureAcompte.rang.toString();
    _pourcentageController.text = widget.factureAcompte.pourcentage.toString();
    _dialog = SimpleFontelicoProgressDialog(context: context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SimpleTextField(
            label: "Rang",
            textController: _rangController,
            readOnly: true,
          ),
          SimpleTextField(
            label: "Pourcentage (en %)",
            textController: _pourcentageController,
            readOnly: true,
            keyboardType: TextInputType.number,
           ),
          DateField(
              label: "Date d'envoi",
              dateController: _dateEnvoieFactureController,
              onCompleteDate: (value) {
                if (value != null) {
                  setState(() {
                    dateEnvoieFacture = value;
                  });
                  _dateEnvoieFactureController.text =
                      getStringDate(time: value);
                }
              },
              lastDate: dateEnvoieFacture,
              firstDate: dateEnvoieFacture),
              if (hasPermission(
            role: widget.role,
            permission: PermissionAlias.exonorerFacturePenalty.label,
          ))
          CustomRadioGroup(
            label: "Appliquer les règles de pénalité",
            groupValue: canPenalty,
            onChanged: (bool? value) {
              setState(() {
                canPenalty = value!;
              });
            },
            defaultValue: true,
          ),
          if (widget.factureAcompte.datePayementEcheante != null) ...[
            DurationField(
              label: "Délai de paiement",
              onUnityChanged: (value) {
                setState(
                  () {
                    unit = value;
                  },
                );
              },
              unitSelectItem: unit,
              controller: _compterController,
            ),
            if (unit != initialUnit ||
                (_compterController.text.isNotEmpty &&
                    initCompter != _compterController.text))
              SimpleTextField(
                label: "Commentaire",
                textController: _commentaireController,
                readOnly: false,
              ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ValidateButton(
                  onPressed: updateFacture,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? validateFields() {
    if (_dateEnvoieFactureController.text.isEmpty) {
      return "Veuillez renseigner la date d'envoi de facture.";
    }

    if (widget.factureAcompte.datePayementEcheante != null &&
        widget.factureAcompte.datePayementEcheante != dateEcheantePayement) {
      if (_dateEcheanteController.text.isEmpty ||
          _commentaireController.text.isEmpty) {
        return "Veuillez renseigner le date d'échéance et justifier la modification";
      }
    }

    return null;
  }

  updateFacture() async {
    String? errMessage;
    if (unit != initialUnit ||
        (_compterController.text.isNotEmpty &&
            initCompter != _compterController.text)) {
      errMessage = validateFields();
    }
    if (errMessage != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errMessage,
      );
      return;
    }

    if (widget.factureAcompte.datePayementEcheante != null) {
      int? compteur = int.tryParse(_compterController.text);
      if ((compteur != null && unit == null) ||
          (compteur == null && unit != null)) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.customError,
          customMessage: "Veuillez remplir les deux champs de date d'écheance.",
        );
        return;
      }
      setState(() {
        dateEcheantePayement = widget.factureAcompte.dateEnvoieFacture.add(
          Duration(
            milliseconds: compteur! * unitMultipliers[unit!]!,
          ),
        );
      });
    }

    if (dateEnvoieFacture != widget.factureAcompte.dateEnvoieFacture) {
      newDateEnvoieFacture = dateEnvoieFacture;
    }

    if (newDateEnvoieFacture == null &&
        newDateEcheantePayement == null &&
        widget.factureAcompte.canPenalty == canPenalty) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Aucune modification n'a été apportée.",
      );
      return;
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      user = await AuthService().decodeToken();
    } catch (err) {
       

      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.serverError,
        customMessage: "Enregistrement échoué",
      );
      return;
    }

    RequestResponse result = await FactureService.updateFactureAccompte(
      factureId: widget.factureId,
      dateEnvoieFacture: newDateEnvoieFacture,
      datePayementEcheante: newDateEcheantePayement,
      canPenalty: canPenalty,
      rang: widget.factureAcompte.rang,
      comment: _commentaireController.text.isEmpty
          ? null
          : CommentModel(
              message: _commentaireController.text,
              date: DateTime.now(),
              editer: user!,
            ),
    );

    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Facture d'acompte mise à jour avec succès",
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
