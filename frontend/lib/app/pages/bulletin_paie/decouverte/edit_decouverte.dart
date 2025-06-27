 
import 'package:flutter/material.dart';
import 'package:frontend/model/bulletin_paie/salarie_model.dart';
import 'package:frontend/service/salarie_service.dart';
import '../../../../helper/get_bulletin_period.dart';
import '../../../../model/entreprise/banque.dart';
import '../../../../model/moyen_paiement_model.dart';
import '../../../../model/personnel/enum_personnel.dart';
import '../../../../model/request_response.dart';
import '../../../../service/banque_service.dart';
import '../../../../service/decouverte_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../model/bulletin_paie/decouverte_model.dart';
import '../../../../service/moyen_paiement_service.dart';
import '../../../../widget/future_dropdown_field.dart';
import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';

class EditDecouvertePage extends StatefulWidget {
  final VoidCallback refresh;
  final DecouverteModel decouverte;
  const EditDecouvertePage({
    super.key,
    required this.decouverte,
    required this.refresh,
  });

  @override
  State<EditDecouvertePage> createState() => _EditDecouvertePageState();
}

class _EditDecouvertePageState extends State<EditDecouvertePage> {
  final TextEditingController _dureeReversementController =
      TextEditingController();
  final TextEditingController _justificationController =
      TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  SalarieModel? salarie;
  DateTime? date;
  double? montant;
  String? referenceTransaction;
  final referenceTransactionFieldController = TextEditingController();
  String? justification;
  MoyenPaiementModel? moyenPayement;
  BanqueModel? banque;
  int? dureeReversement;
  late SimpleFontelicoProgressDialog _dialog;

  editDecouverte({required DecouverteModel decouverte}) async {
    if (salarie == null ||
        _montantController.text.isEmpty ||
        _dureeReversementController.text.isEmpty ||
        _justificationController.text.isEmpty ||
        referenceTransactionFieldController.text.isEmpty ||
        moyenPayement == null ||
        banque == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir tous les champs obligatoires.",
      );
      return;
    }
    if (double.parse(_montantController.text) == 0 ||
        int.parse(_dureeReversementController.text) == 0) {
      MutationRequestContextualBehavior.showPopup(
        customMessage: "Tout nombre doit être supérieur à zéro",
        status: PopupStatus.customError,
      );
      return;
    }
    if (!hasChanged()) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Aucune modification détectée",
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

    if (_justificationController.text.trim() !=
        widget.decouverte.justification) {
      justification = _justificationController.text.trim();
    }
    if (referenceTransactionFieldController.text.trim() !=
        widget.decouverte.referenceTransaction) {
      referenceTransaction = referenceTransactionFieldController.text.trim();
    }
    if (_montantController.text.trim() !=
        widget.decouverte.montant.toString()) {
      montant = double.parse(_montantController.text);
    }
    if (_dureeReversementController.text.trim() !=
        widget.decouverte.dureeReversement.toString()) {
      dureeReversement = int.parse(_dureeReversementController.text);
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    RequestResponse result = await DecouverteService.updateDecouverte(
        key: decouverte.id,
        dureeReversement: dureeReversement,
        justification: justification,
        montant: montant,
        banque: banque,
        referenceTransaction: referenceTransaction,

        moyenPayement: moyenPayement!,
        salarie: salarie);
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Découvert mise à jour avec succès",
      );
      widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }

  Future<List<SalarieModel>> fetchSalariesData() async {
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

    _montantController.text = widget.decouverte.montant.toString();
    salarie = widget.decouverte.salarie;
    banque = widget.decouverte.banque;
    referenceTransactionFieldController.text =
        widget.decouverte.referenceTransaction!;
    moyenPayement = widget.decouverte.moyenPayement;
    _justificationController.text = widget.decouverte.justification;
    _dureeReversementController.text =
        widget.decouverte.dureeReversement.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: UniqueKey(),
      child: Column(
        children: [
          FutureCustomDropDownField(
            label: "Salarié",
            selectedItem: salarie,
            fetchItems: fetchSalariesData,
            onChanged: (value) {
              setState(() {
                salarie = value!;
              });
            },
            itemsAsString: (salarie) => salarie.personnel.toStringify(),
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
                onPressed: () {
                  editDecouverte(
                    decouverte: widget.decouverte,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  bool hasChanged() {
    return (_justificationController.text.trim() !=
            widget.decouverte.justification ||
        double.parse(_montantController.text.trim()) !=
            widget.decouverte.montant ||
        _dureeReversementController.text.trim() !=
            widget.decouverte.dureeReversement.toString() ||
        banque != widget.decouverte.banque ||
        referenceTransactionFieldController.text.trim() !=
            widget.decouverte.referenceTransaction ||
        moyenPayement != widget.decouverte.moyenPayement ||
        salarie != widget.decouverte.salarie);
  }
}
