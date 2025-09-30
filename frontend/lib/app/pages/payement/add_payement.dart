import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/helper/amout_formatter.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import '../../../model/entreprise/banque.dart';
import '../../../service/banque_service.dart';
import '../../../service/moyen_paiement_service.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../integration/popop_status.dart';
import '../../../helper/date_helper.dart';
import '../../../helper/facture_proforma_helper.dart';
import '../../../model/facturation/facture_model.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../model/request_response.dart';
import '../../../service/payement_service.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/file_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../auth/authentification_token.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/request_frot_behavior.dart';

class AddPayement extends StatefulWidget {
  final Future<void> Function() refresh;
  final FactureModel facture;
  const AddPayement({
    super.key,
    required this.facture,
    required this.refresh,
  });

  @override
  State<AddPayement> createState() => _AddFluxPageState();
}

class _AddFluxPageState extends State<AddPayement> {
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final referenceTransactionFieldController = TextEditingController();
  DateTime? dateOperation;
  MoyenPaiementModel? moyenPayement;
  BanqueModel? _selectedBank;

  PlatformFile? file;
  late SimpleFontelicoProgressDialog _dialog;
  late double amounttopay;
  UserModel? user;
  List<BanqueModel> banques = [];
 
  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    calculateAmountToPay();
    _amountController.text =
        "${widget.facture.montant! * widget.facture.facturesAcompte[widget.facture.payements!.length].pourcentage / 100}";
  }
  void calculateAmountToPay() {
    double montantPaye = (widget.facture.payements != null &&
            widget.facture.payements!.isNotEmpty)
        ? calculerMontantPaye(payements: widget.facture.payements!)
        : 0.0;
    montantPaye += widget.facture
            .facturesAcompte[widget.facture.payements!.length].oldPenalties
            ?.fold(0.0, (sum, penalty) => sum! + penalty.montant) ??
        0.0;
      amounttopay = widget.facture.montant! - montantPaye;
    _amountController.text = amounttopay.toString();
  }

  Future<void> addPayement({
    required FactureModel facture,
  }) async {
    try {
      String errorMessage = "";
      if (moyenPayement == null ||
          referenceTransactionFieldController.text.isEmpty ||
          _selectedBank == null) {
        errorMessage = "Veuillez remplir tous les champs marqués.";
    }
    if (amounttopay < double.parse(_amountController.text)) {
      errorMessage =
            "le montant restant à payer est bien inférieur à ${_amountController.text} FCFA";
    }
    if (errorMessage.isNotEmpty) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errorMessage,
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
    RequestResponse result = await PayementService.ajouterPayement(
      factureId: facture.id,
      montant: double.parse(_amountController.text),
      moyenPayement: moyenPayement!,
      file: file,
      userId: user!.id!,
        clientId: facture.client!.id,
        bank: _selectedBank!,
        referenceTransaction: referenceTransactionFieldController.text,
      dateOperation: dateOperation,
    );
    _dialog.hide();
    if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Encaissement enrégistré avec succès",
      );
      await widget.refresh();
      calculateAmountToPay();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
    } catch (e) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: e.toString(),
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
Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return _selectedBank == null
        ? await MoyenPaiementService.getMoyenPaiements()
        : (await MoyenPaiementService.getMoyenPaiements())
            .where((m) => m.type == _selectedBank!.type)
            .toList();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        //key: UniqueKey(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Facture",
                  ),
                  Text(
                    widget.facture.reference,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            const Gap(4),
            Container(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Client",
                  ),
                  Text(
                    widget.facture.client!.toStringify(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            const Gap(4),
            Container(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Montant total à payer",
                  ),
                  Text(
                    "${Formatter.formatAmount(widget.facture.montant!)} FCFA",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Montant déjà payé",
                  ),
                  Text(
                    "${Formatter.formatAmount(widget.facture.montant! - amounttopay)} FCFA",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Montant restant à payer",
                  ),
                  Text(
                    "${Formatter.formatAmount(amounttopay)} FCFA",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(4),
            if (widget.facture.facturesAcompte.isNotEmpty)
              ...widget.facture.facturesAcompte.map((toElement) {
                int rang = widget.facture.payements!.length + 1;
                Color rowColor;
                if (toElement.rang < rang) {
                  rowColor = Colors.green.withOpacity(0.3);
                } else if (toElement.rang == rang) {
                  rowColor = Colors.blue.withOpacity(0.3);
                } else {
                  rowColor = const Color(0xFFFFFACD).withOpacity(0.6);
                }
                return Container(
                  color: rowColor,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Encaissement ${toElement.rang}"),
                      Text("${toElement.pourcentage}%"),
                      Text(
                        "${Formatter.formatAmount(widget.facture.montant! * toElement.pourcentage / 100)} FCFA",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const Gap(8),
            SimpleTextField(
              label: "Montant",
              textController: _amountController,
              keyboardType: TextInputType.number,
              readOnly: true,
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
              selectedItem: _selectedBank,
              fetchItems: fetchBanqueItems,
              onChanged: (BanqueModel? value) {
                // if (value != null) {
                setState(() {
                  _selectedBank = value;
                });
                // }
              },
              canClose: true,
              itemsAsString: (s) => s.name,
            ),
            DateField(
              onCompleteDate: (value) {
                _dateController.text = getStringDate(time: value!);
                dateOperation = value;
              },
              label: "Date de payement",
              lastDate: DateTime.now(),
              dateController: _dateController,
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
              platformFile: file,
              removeFile: () => setState(() {
                file = null;
              }),
              pickFile: (p0) {
                setState(() {
                  file = p0;
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
                  onPressed: () async {
                    await addPayement(
                      facture: widget.facture,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
