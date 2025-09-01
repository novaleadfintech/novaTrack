import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/client/client_model.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/flux_financier/flux_financier_model.dart';
import 'package:frontend/model/flux_financier/libelle_flux.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/service/banque_service.dart';
import 'package:frontend/service/client_service.dart';
import 'package:frontend/service/moyen_paiement_service.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../auth/authentification_token.dart';
import '../../../helper/date_helper.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../widget/date_text_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';

import '../../integration/popop_status.dart';

class PayDebt extends StatefulWidget {
  final FluxFinancierModel flux;
  final Future<void> Function() refresh;
  const PayDebt({
    super.key,
    required this.refresh,
    required this.flux,
  });

  @override
  State<PayDebt> createState() => _PayDebtState();
}

class _PayDebtState extends State<PayDebt> {
  final libelleFieldController = TextEditingController();
  final amountFieldController = TextEditingController();
  final referenceTransactionFieldController = TextEditingController();
  final montantPayeTextFieldController = TextEditingController();
  final dateFieldController = TextEditingController();
  DateTime? dateOperation;
  MoyenPaiementModel? moyenPayement;
  PlatformFile? file;
  late SimpleFontelicoProgressDialog _dialog;
  UserModel? user;
  LibelleFluxModel? libelleType;
  ClientModel? client;
  BanqueModel? banque;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> addFlux() async {
    if (libelleFieldController.text.isEmpty ||
        amountFieldController.text.isEmpty ||
        referenceTransactionFieldController.text.isEmpty ||
        moyenPayement == null ||
        banque == null ||
        client == null ||
        libelleType == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuiller remplir tous les champs marqués",
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
        customMessage: "Enégistrement échoué",
      );
      return;
    }
    // RequestResponse result = await FluxFinancierService.createFluxFinancier(
    //   libelle: "${libelleType!.libelle} : ${libelleFieldController.text}",
    //   montant: double.parse(amountFieldController.text),
    //   moyenPayement: moyenPayement!,
    //   type: widget.type,
    //   referenceTransaction: referenceTransactionFieldController.text,
    //   dateOperation: dateOperation,
    //   client: client!,
    //   file: file,
    //   banque: banque!,
    //   userId: user!.id!,
    //   modePayement: _modePayement,
    //   montantPaye: double.tryParse(montantPayeTextFieldController.text),
    //   tranchePayement: _modePayement != BuyingManner.total
    //       ? [
    //           TranchePayementModel(
    //             datePayement: dateOperation ?? DateTime.now(),
    //             montantPaye: double.parse(montantPayeTextFieldController.text),
    //           )
    //         ]
    //       : [],
    // );
    // _dialog.hide();
    // if (result.status == PopupStatus.success) {
    //   MutationRequestContextualBehavior.closePopup();
    //   MutationRequestContextualBehavior.showPopup(
    //     status: PopupStatus.success,
    //     customMessage: widget.type == FluxFinancierType.input
    //         ? "Entrée enrégistrée avec succès"
    //         : "Sortie enrégistrée avec succès",
    //   );
    //   await widget.refresh();
    // } else {
    //   MutationRequestContextualBehavior.showPopup(
    //     status: result.status,
    //     customMessage: result.message,
    //   );
    // }
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return moyenPayement == null
        ? await BanqueService.getAllBanques()
        : (await BanqueService.getAllBanques())
            .where((b) => b.type == moyenPayement!.type)
            .toList();
  }

  Future<List<ClientModel>> fetchClientItems() async {
    return await ClientService.getUnarchivedClients();
  }

  Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return banque == null
        ? await MoyenPaiementService.getMoyenPaiements()
        : (await MoyenPaiementService.getMoyenPaiements())
            .where((m) => m.type == banque!.type)
            .toList();
  }

  Future<List<ClientModel>> fetchFournisseurItems() async {
    return await ClientService.getUnarchivedFournisseur();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        //key: UniqueKey(),
        child: Column(
          children: [
            SimpleTextField(
              label: "Montant payé",
              textController: montantPayeTextFieldController,
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
            DateField(
              onCompleteDate: (value) {
                setState(() {
                  dateOperation = value!;
                  dateFieldController.text = getStringDate(time: value);
                });
              },
              label: "Date de paiement",
              dateController: dateFieldController,
              lastDate: DateTime.now(),
            ),
            SimpleTextField(
              label:
                  "Référence de la transaction ${moyenPayement != null ? " (${moyenPayement!.libelle})" : ""}",
              textController: referenceTransactionFieldController,
              keyboardType: TextInputType.text,
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: addFlux,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
