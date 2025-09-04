import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/client/client_model.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/flux_financier/debt_model.dart';
import 'package:frontend/model/flux_financier/type_flux_financier.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/service/banque_service.dart';
import 'package:frontend/service/client_service.dart';
import 'package:frontend/service/debt_service.dart';
import 'package:frontend/service/moyen_paiement_service.dart';
import '../../../model/request_response.dart';
import '../../../service/flux_financier_service.dart';
import '../../../widget/file_field.dart';
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
  final DebtModel debt;
  final Future<void> Function() refresh;
  const PayDebt({
    super.key,
    required this.debt,
    required this.refresh,
  });

  @override
  State<PayDebt> createState() => _PayDebtState();
}

class _PayDebtState extends State<PayDebt> {
  final libelleFieldController = TextEditingController();
  final referenceTransactionFieldController = TextEditingController();
  final montantPayeTextFieldController = TextEditingController();
  final dateFieldController = TextEditingController();
  DateTime? dateOperation;
  MoyenPaiementModel? moyenPayement;
  PlatformFile? _file;
  late SimpleFontelicoProgressDialog _dialog;
  UserModel? user;
  ClientModel? client;
  BanqueModel? banque;

  @override
  void initState() {
    super.initState();
    client = widget.debt.client;
    libelleFieldController.text = widget.debt.libelle;
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> addFlux() async {
    if (libelleFieldController.text.isEmpty ||
        montantPayeTextFieldController.text.isEmpty ||
        referenceTransactionFieldController.text.isEmpty ||
        moyenPayement == null ||
        banque == null ||
        client == null) {
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
    RequestResponse result = await FluxFinancierService.createFluxFinancier(
      libelle: libelleFieldController.text,
      montant: double.parse(montantPayeTextFieldController.text),
      moyenPayement: moyenPayement!,
      type: FluxFinancierType.input,
      referenceTransaction: referenceTransactionFieldController.text,
      dateOperation: dateOperation,
      client: client!,
      file: _file,
      banque: banque!,
      userId: user!.id!,
    );
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      RequestResponse debtUpdateresult = await DebtService.updateDebt(
        key: widget.debt.id,
        montant: widget.debt.montant -
            double.parse(montantPayeTextFieldController.text),
        referenceFacture: null,
        client: null,
        dateOperation: null,
        file: null,
        libelle: null,
      );
      if (debtUpdateresult.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: 'Payement enregistré avec succès',
        );
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
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
            FileField(
              canTakePhoto: true,
              label: "Pièce justificative",
              platformFile: _file,
              removeFile: () => setState(() {
                _file = null;
              }),
              pickFile: (p0) {
                setState(() {
                  _file = p0;
                });
              },
              required: false,
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
