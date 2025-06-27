import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/user_model.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../helper/date_helper.dart';
import '../../../model/commentaire_model.dart';
import '../../../model/request_response.dart';
import '../../../service/facture_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/facturation/facture_model.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';

class AddCommentPage extends StatefulWidget {
  final FactureModel facture;
  final VoidCallback refresh;

  const AddCommentPage({
    super.key,
    required this.facture,
    required this.refresh,
  });

  @override
  State<AddCommentPage> createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  final TextEditingController _commentaireController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;
  UserModel? user;

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Commentaires précédents",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Gap(8),
        SingleChildScrollView(
          child: Column(
            children: widget.facture.commentaires
                .map((toElement) => Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              topRight: Radius.circular(16))),
                      margin: EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  toElement!.message,
                                ),
                              ),
                            ],
                          ),
                          Gap(8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${getShortStringDate(time: toElement.date)} à ${DateFormat.Hm().format(toElement.date)}",
                                style: const TextStyle(fontSize: 10),
                              ),
                              Text(
                                "Par ${toElement.editer!.toStringify()}",
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          )
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        const Gap(4),
        SimpleTextField(
          label: "Commentaire",
          textController: _commentaireController,
          expands: true,
          maxLines: null,
          height: 80,
          required: false,
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: () {
                addComment(factureId: widget.facture.id);
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  void addComment({required String factureId}) async {
    if (_commentaireController.text.trim().isEmpty) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez mettre un commentaire.",
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

    RequestResponse response = await FactureService.updateFacture(
      comment: CommentModel(
        message: _commentaireController.text.trim(),
        date: DateTime.now(),
        editer: user,
      ),
      clientId: null,
      dateDebutFacturation: null,
      dateEtablissement: null,
      factureId: factureId,
      generatePeriod: null,
      reduction: null,
      tva: null,
    );
    _dialog.hide();
    if (response.status == PopupStatus.success) {
      setState(() {
        widget.facture.commentaires.add(
          CommentModel(
            message: _commentaireController.text,
            date: DateTime.now(),
            editer: user!,
          ),
        );
        _commentaireController.clear();
      });
      MutationRequestContextualBehavior.showPopup(
        status: response.status,
        customMessage: "Commentaire ajouté avec succès",
      );
      widget.refresh();
      MutationRequestContextualBehavior.closePopup();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: response.status,
        customMessage: response.message,
      );
    }
  }
}
