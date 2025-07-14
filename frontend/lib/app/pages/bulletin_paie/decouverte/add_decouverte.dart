import 'package:flutter/material.dart';
import 'package:frontend/helper/get_bulletin_period.dart';
import 'package:frontend/model/bulletin_paie/salarie_model.dart';
import 'package:frontend/model/habilitation/user_model.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/model/personnel/enum_personnel.dart';
import 'package:frontend/service/decouverte_service.dart';
import 'package:frontend/service/salarie_service.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../auth/authentification_token.dart';
 import '../../../../model/entreprise/banque.dart';
import '../../../../service/banque_service.dart';
import '../../../../service/moyen_paiement_service.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import 'package:gap/gap.dart';
import '../../../../widget/future_dropdown_field.dart';
import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';

class AddDecouvertePage extends StatefulWidget {
  final VoidCallback refresh;
  const AddDecouvertePage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddDecouvertePage> createState() => _AddDecouvertePageState();
}

class _AddDecouvertePageState extends State<AddDecouvertePage> {
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _justificationController =
      TextEditingController();
  final referenceTransactionFieldController = TextEditingController();

  final TextEditingController _dureeReversementController =
      TextEditingController();
  SalarieModel? salarie;
  late SimpleFontelicoProgressDialog _dialog;
  UserModel? user;
  MoyenPaiementModel? moyenPayement;
  BanqueModel? banque;
  Future<List<SalarieModel>> fetchItems() async {
    return await SalarieService.getSalaries();
  }

  
  Future<List<BanqueModel>> fetchBanqueItems() async {
    return moyenPayement == null
        ? await BanqueService.getAllBanques()
        : (await BanqueService.getAllBanques())
            .where((b) => b.type == moyenPayement!.type)
            .toList();
  }
Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return banque == null
        ? await MoyenPaiementService.getMoyenPaiements()
        : (await MoyenPaiementService.getMoyenPaiements())
            .where((m) => m.type == banque!.type)
            .toList();
  }

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        //key: UniqueKey(),
        child: Column(
          children: [
            FutureCustomDropDownField<SalarieModel>(
              label: "Salarié",
              selectedItem: salarie,
              fetchItems: fetchItems,
              onChanged: (value) {
                setState(() {
                  salarie = value;
                });
              },
              itemsAsString: (SalarieModel salarie) =>
                  "${salarie.personnel.nom} ${salarie.personnel.prenom}",
            ),
            SimpleTextField(
              label: "Montant",
              textController: _montantController,
              keyboardType: TextInputType.number,
            ),
            FutureCustomDropDownField<MoyenPaiementModel>(
              label: "Moyen de paiement",
              selectedItem: moyenPayement,
              fetchItems: fetchMoyenPaiementItems,
              onChanged: (MoyenPaiementModel? value) {
                // if (value != null) {
                setState(() {
                  moyenPayement = value;
                });
                // }
              },
              canClose: true,
              itemsAsString: (s) => s.libelle,
            ),
            FutureCustomDropDownField<BanqueModel>(
              label: "Compte de payement",
              showSearchBox: true,
              selectedItem: banque,
              fetchItems: fetchBanqueItems,
              onChanged: (BanqueModel? value) {
                // if (value != null) {
                setState(() {
                  banque = value;
                });
                // }
              },
              canClose: true,
              itemsAsString: (s) => s.name,
            ),
            SimpleTextField(
              label:
                  "Référence de la transaction ${moyenPayement != null ? " (${moyenPayement!.libelle})" : ""}",
              textController: referenceTransactionFieldController,
              keyboardType: TextInputType.text,
            ),
            SimpleTextField(
              label: "Durée de reversement (fois)",
              textController: _dureeReversementController,
              keyboardType: TextInputType.number,
            ),
            SimpleTextField(
              label: "Justification",
              textController: _justificationController,
              expands: true,
              required: true,
              maxLines: null,
              height: 80,
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () async {
                    await _addDecouverte();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addDecouverte() async {
    if (salarie == null ||
        _montantController.text.isEmpty ||
        _dureeReversementController.text.isEmpty ||
        _justificationController.text.isEmpty ||
        referenceTransactionFieldController.text.isEmpty ||
        banque == null ||
        moyenPayement == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir tous les champs obligatoires.",
      );
      return;
    }
    if (int.parse(_montantController.text) == 0 ||
        int.parse(_dureeReversementController.text) == 0) {
      MutationRequestContextualBehavior.showPopup(
        customMessage: "Tout nombre doit être supérieur à zéro",
        status: PopupStatus.information,
      );
      return;
    }
    if (salarie!.personnel.typeContrat != TypeContrat.cdi) {
      if (salarie!.personnel.dateDebut != null &&
          salarie!.personnel.dateFin != null) {
        (salarie: salarie!);
        if (int.parse(_dureeReversementController.text) >
            countValidPeriodsRestant(salarie: salarie!)) {
          MutationRequestContextualBehavior.showPopup(
            customMessage:
                "Vous ne pouvez pas payer votre avance en ${int.parse(_dureeReversementController.text)} temps",
            status: PopupStatus.information,
          );
          return;
        }
      }
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
        customMessage: "Enégistrement échoué",
      );
      return;
    }
    try {
      var result = await DecouverteService.createDecouverte(
      dureeReversement: int.parse(_dureeReversementController.text),
      justification: _justificationController.text.trim(),
      montant: double.parse(_montantController.text),
      salarieId: salarie!.id,
        referenceTransaction: referenceTransactionFieldController.text.trim(),

      userId: user!.id!,
      moyenPayement: moyenPayement!,
      banque: banque!,
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Découvert enrégistrement avec succès",
      );
      widget.refresh();
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
      return;
    }
  }
}
