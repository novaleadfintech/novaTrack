import 'package:flutter/material.dart';
import 'package:frontend/model/request_response.dart';
import 'package:frontend/service/poste_service.dart';
import '../../../helper/date_helper.dart';
import '../../../helper/personne_helper.dart';
import '../../../helper/telephone_number_helper.dart';
import '../../../model/personnel/enum_personnel.dart';
import '../../../model/personnel/personne_prevenir.dart';
import '../../../model/personnel/poste_model.dart';
import '../../../service/pays_service.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../responsitvity/responsivity.dart';
import '../../../model/pays_model.dart';
import '../../../model/common_type.dart';
import '../../../model/personnel/personnel_model.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../global/constant/request_management_value.dart';
import '../../../service/personnel_service.dart';
import '../../../widget/telephone_field.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class EditPersonnelPage extends StatefulWidget {
  final Future<void> Function() refresh;
  final PersonnelModel personnel;

  const EditPersonnelPage({
    super.key,
    required this.refresh,
    required this.personnel,
  });

  @override
  State<EditPersonnelPage> createState() => _EditPersonnelPageState();
}

class _EditPersonnelPageState extends State<EditPersonnelPage> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _commentaireController;
  // late TextEditingController _posteController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  PaysModel? _selectedCountry;
  PosteModel? _selectedPoste;

  Sexe? sexe;
  SituationMatrimoniale? situationMatrimoniale;
  late SimpleFontelicoProgressDialog _dialog;
//nouveau donnée
  String? newnom;
  String? newprenom;
  String? newemail;
  String? newcommentaire;
  PosteModel? newposte;
  int? newtelephone;
  PaysModel? newpays;
  PaysModel? newPoste;
  String? newadresse;
  Sexe? newSexe;
  SituationMatrimoniale? newSituationMatrimoniale;

  late TextEditingController _dateNaissanceController;
  late TextEditingController _dateDebutController;
  late TextEditingController _dateFinController;
  late TextEditingController _nombreEnfantController;
  late TextEditingController _nombrePersonneChargeController;
  late TextEditingController _nomPersonnePrevenirController;
  late TextEditingController _lienController;
  late TextEditingController _telephone1Controller;
  late TextEditingController _telephone2Controller;
  late TextEditingController _dureeEssaiController;

  DateTime? dateNaissance;
  DateTime? dateDebut;
  DateTime? dateFin;
  TypePersonnel? typePersonnel;
  TypeContrat? typeContrat;
  PersonnePrevenirModel? personnePrevenir;
  int? dureeEssai;
  DateTime? newDateNaissance;
  DateTime? newDateDebut;
  DateTime? newDateFin;
  int? newNombreEnfant;
  int? newNombrePersonneCharge;
  String? newNomPersonnePrevenir;
  String? newLien;
  int? newTelephone1;
  int? newTelephone2;
  TypePersonnel? newTypePersonnel;
  TypeContrat? newTypeContrat;
  PersonnePrevenirModel? newPersonnePrevenir;

  @override
  void initState() {
    super.initState();

    // Initialiser les champs avec les données du personnel existant
    _nomController = TextEditingController(text: widget.personnel.nom);
    _prenomController = TextEditingController(text: widget.personnel.prenom);
    _emailController = TextEditingController(text: widget.personnel.email);
    _commentaireController =
        TextEditingController(text: widget.personnel.commentaire ?? '');
    _telephoneController =
        TextEditingController(text: widget.personnel.telephone.toString());
    _adresseController = TextEditingController(text: widget.personnel.adresse);
    _selectedCountry = widget.personnel.pays!;
    _selectedPoste = widget.personnel.poste;
    _dureeEssaiController = TextEditingController(
        text: (widget.personnel.dureeEssai != null
                ? (widget.personnel.dureeEssai!)
                : '')
            .toString());
    sexe = widget.personnel.sexe;
    situationMatrimoniale = widget.personnel.situationMatrimoniale;
    _dialog = SimpleFontelicoProgressDialog(context: context);

    _dateNaissanceController = TextEditingController(
        text: widget.personnel.dateNaissance != null
            ? getStringDate(time: widget.personnel.dateNaissance!)
            : '');
    _dateDebutController = TextEditingController(
        text: widget.personnel.dateDebut != null
            ? getStringDate(time: widget.personnel.dateDebut!)
            : '');
    _dateFinController = TextEditingController(
        text: widget.personnel.dateFin != null
            ? getStringDate(time: widget.personnel.dateFin!)
            : '');
    _nombreEnfantController = TextEditingController(
        text: widget.personnel.nombreEnfant?.toString() ?? '');
    _nombrePersonneChargeController = TextEditingController(
        text: widget.personnel.nombrePersonneCharge?.toString() ?? '');
    _nomPersonnePrevenirController = TextEditingController(
        text: widget.personnel.personnePrevenir?.nom ?? '');
    _lienController = TextEditingController(
        text: widget.personnel.personnePrevenir?.lien ?? '');
    _telephone1Controller = TextEditingController(
        text: widget.personnel.personnePrevenir?.telephone1.toString() ?? '');
    _telephone2Controller = TextEditingController(
        text: widget.personnel.personnePrevenir?.telephone2 == null
            ? ""
            : widget.personnel.personnePrevenir?.telephone2.toString());
    dateNaissance = widget.personnel.dateNaissance;
    dateDebut = widget.personnel.dateDebut;
    dateFin = widget.personnel.dateFin;
    typePersonnel = widget.personnel.typePersonnel;
    typeContrat = widget.personnel.typeContrat;
    personnePrevenir = widget.personnel.personnePrevenir;
  }

  bool hasChanges() {
    // Comparer les valeurs actuelles avec celles du personnel initial
    return _nomController.text.trim() != widget.personnel.nom ||
        _prenomController.text.trim() != widget.personnel.prenom ||
        _emailController.text.trim() != widget.personnel.email ||
        _commentaireController.text.trim() !=
            (widget.personnel.commentaire ?? '') ||
        _selectedPoste != widget.personnel.poste ||
        _telephoneController.text.trim() !=
            widget.personnel.telephone.toString() ||
        _adresseController.text.trim() != (widget.personnel.adresse ?? '') ||
        sexe != widget.personnel.sexe ||
        situationMatrimoniale != widget.personnel.situationMatrimoniale ||
        _selectedCountry! != widget.personnel.pays! ||
        _dateNaissanceController.text.trim() !=
            getStringDate(time: widget.personnel.dateNaissance!) ||
        _dateDebutController.text.trim() !=
            getStringDate(time: widget.personnel.dateDebut!) ||
        _dateFinController.text.trim() !=
            getStringDate(time: widget.personnel.dateFin!) ||
        _nombreEnfantController.text.trim() !=
            widget.personnel.nombreEnfant?.toString() ||
        _nombrePersonneChargeController.text.trim() !=
            widget.personnel.nombrePersonneCharge?.toString() ||
        _dureeEssaiController.text.trim() !=
            (widget.personnel.dureeEssai != null
                    ? (widget.personnel.dureeEssai!)
                    : 0)
                .toString() ||
        _nomPersonnePrevenirController.text.trim() !=
            widget.personnel.personnePrevenir?.nom ||
        _lienController.text.trim() !=
            widget.personnel.personnePrevenir?.lien ||
        _telephone1Controller.text.trim() !=
            widget.personnel.personnePrevenir?.telephone1.toString() ||
        _telephone2Controller.text.trim() !=
            (widget.personnel.personnePrevenir?.telephone2 == null
                ? ""
                : widget.personnel.personnePrevenir?.telephone2.toString()) ||
        typePersonnel != widget.personnel.typePersonnel ||
        typeContrat != widget.personnel.typeContrat;
  }

  Future<void> updatePersonnel({required PersonnelModel personnel}) async {
    final String nom = _nomController.text.trim();
    final String prenom = _prenomController.text.trim();
    final String email = _emailController.text.trim();
    final String adresse = _adresseController.text.trim();

    final String telephone = _telephoneController.text.trim();

    String? errorMessage;
    if (nom.isEmpty ||
        prenom.isEmpty ||
        _selectedPoste == null ||
        sexe == null ||
        _selectedCountry == null ||
        situationMatrimoniale == null ||
        telephone.isEmpty ||
        email.isEmpty ||
        typePersonnel == null ||
        typeContrat == null ||
        adresse.isEmpty ||
        _dateNaissanceController.text.trim().isEmpty ||
        _dateDebutController.text.trim().isEmpty ||
        _nombreEnfantController.text.trim().isEmpty ||
        _nombrePersonneChargeController.text.trim().isEmpty ||
        _nomPersonnePrevenirController.text.trim().isEmpty ||
        _lienController.text.trim().isEmpty ||
        _telephone1Controller.text.trim().isEmpty) {
      errorMessage = "Tous les champs marqués doivent être remplis.";
    }

    // if (typePersonnel == TypePersonnel.employe && typeContrat == null) {
    //   errorMessage = "Tous les champs marqués doivent être remplis.";
    // }

    if ((typeContrat == TypeContrat.cdd ||
            typePersonnel == TypePersonnel.stagiaire) &&
        dateFin == null) {
      errorMessage = "Tous les champs marqués doivent être remplis.";
    }

    if (dateDebut != null && dateFin != null) {
      if (dateDebut!
          .add(Duration(
              milliseconds: ((int.tryParse(_dureeEssaiController.text) ?? 0) *
                  (unitMultipliers['mois'] ?? 0))))
          .isAfter(dateFin!)) {
        errorMessage =
            "La date de fin du contrat ne peut pas être antérieure à la fin de la période d'essai.";
      }
    }

    errorMessage = errorMessage ??
        checkPhoneNumber(
          phoneNumber: _telephoneController.text.trim(),
          pays: _selectedCountry!,
        ) ??
        checkPhoneNumber(
          phoneNumber: _telephone1Controller.text.trim(),
          pays: _selectedCountry!,
        );

    if (errorMessage == null && _telephone2Controller.text.isNotEmpty) {
      errorMessage = checkPhoneNumber(
        phoneNumber: _telephone2Controller.text.trim(),
        pays: _selectedCountry!,
      );
    }
    if (errorMessage != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errorMessage,
      );
      return;
    }

    if (_nomController.text.trim() != widget.personnel.nom) {
      newnom = _nomController.text.trim();
    }
    if (_prenomController.text.trim() != widget.personnel.prenom) {
      newprenom = _prenomController.text.trim();
    }
    if (_emailController.text.trim() != widget.personnel.email) {
      newemail = _emailController.text.trim();
    }
    if (_commentaireController.text.trim() !=
        (widget.personnel.commentaire ?? '')) {
      newcommentaire = _commentaireController.text.trim();
    }
    if (_selectedPoste != widget.personnel.poste) {
      newposte = _selectedPoste;
    }
    if (_telephoneController.text.trim() !=
        widget.personnel.telephone.toString()) {
      newtelephone = int.parse(_telephoneController.text.trim());
    }
    if (_adresseController.text.trim() != (widget.personnel.adresse ?? '')) {
      newadresse = _adresseController.text.trim();
    }
    if (_dureeEssaiController.text.trim().isNotEmpty) {
      if (_dureeEssaiController.text.trim() !=
          (widget.personnel.dureeEssai != null
                  ? (widget.personnel.dureeEssai!)
                  : 0)
              .toString()) {
        dureeEssai = int.parse(_dureeEssaiController.text.trim());
      }
    }
    if (sexe != widget.personnel.sexe) {
      newSexe = sexe;
    }
    if (_selectedCountry != widget.personnel.pays!) {
      newpays = _selectedCountry;
    }
    if (situationMatrimoniale != widget.personnel.situationMatrimoniale) {
      newSituationMatrimoniale = situationMatrimoniale;
    }
    if (_dateNaissanceController.text.trim() !=
        widget.personnel.dateNaissance?.toString()) {
      newDateNaissance = dateNaissance;
    }
    if (_dateDebutController.text.trim() !=
        widget.personnel.dateDebut?.toString()) {
      newDateDebut = dateDebut;
    }
    if (_dateFinController.text.trim() !=
        widget.personnel.dateFin?.toString()) {
      newDateFin = dateFin;
    }
    if (_nombreEnfantController.text.trim() !=
        widget.personnel.nombreEnfant?.toString()) {
      newNombreEnfant = int.parse(_nombreEnfantController.text.trim());
    }
    if (_nombrePersonneChargeController.text.trim() !=
        widget.personnel.nombrePersonneCharge?.toString()) {
      newNombrePersonneCharge =
          int.parse(_nombrePersonneChargeController.text.trim());
    }
    if (_nomPersonnePrevenirController.text.trim() !=
        widget.personnel.personnePrevenir?.nom) {
      newNomPersonnePrevenir = _nomPersonnePrevenirController.text.trim();
    }
    if (_lienController.text.trim() !=
        widget.personnel.personnePrevenir?.lien) {
      newLien = _lienController.text.trim();
    }
    if (_telephone1Controller.text.trim() !=
        widget.personnel.personnePrevenir?.telephone1.toString()) {
      newTelephone1 = int.parse(_telephone1Controller.text.trim());
    }
    if (_telephone2Controller.text.trim().isNotEmpty) {
      if (_telephone2Controller.text.trim() !=
          widget.personnel.personnePrevenir?.telephone2.toString()) {
        newTelephone2 = int.parse(_telephone2Controller.text.trim());
      }
    } else {
      newTelephone2 = 0;
    }
    if (typePersonnel != widget.personnel.typePersonnel) {
      newTypePersonnel = typePersonnel;
    }
    if (typeContrat != widget.personnel.typeContrat) {
      newTypeContrat = typeContrat;
    }
    if (newNomPersonnePrevenir != null ||
        newLien != null ||
        newTelephone1 != null ||
        newTelephone2 != null) {
      newPersonnePrevenir = PersonnePrevenirModel(
        nom: newNomPersonnePrevenir ?? widget.personnel.personnePrevenir!.nom,
        lien: newLien ?? widget.personnel.personnePrevenir!.lien,
        telephone1:
            newTelephone1 ?? widget.personnel.personnePrevenir!.telephone1,
        telephone2: newTelephone2 == 0 ? null : newTelephone2,
      );
    }
    if (!hasChanges()) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Aucune modification n'a été apportée.",
      );
      return;
    }

    _dialog.show(
      message: RequestMessage.loadinMessage,
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    // Envoyer la requête de modification
    RequestResponse result = await PersonnelService.updatePersonnel(
      key: personnel.id,
      adresse: newadresse,
      commentaire: newcommentaire,
      email: newemail,
      nom: newnom,
      pays: newpays,
      poste: newposte,
      prenom: newprenom,
      sexe: newSexe,
      situationMatrimoniale: newSituationMatrimoniale,
      telephone: newtelephone,
      dateNaissance: newDateNaissance,
      dateDebut: newDateDebut,
      dateFin: newDateFin,
      dureeEssai: dureeEssai,
      nombreEnfant: newNombreEnfant,
      nombrePersonneCharge: newNombrePersonneCharge,
      personnePrevenir: newPersonnePrevenir,
      typePersonnel: newTypePersonnel,
      typeContrat: newTypeContrat,
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Personnel modifié avec succès",
      );
      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }

  Future<List<PaysModel>> fetchCountryItems() async {
    return await PaysService.getAllPays();
  }

  Future<List<PosteModel>> fetchPosteItems() async {
    return await PosteService.getPostes();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    return SingleChildScrollView(
      child: Form(
        //key: UniqueKey(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SimpleTextField(
              label: "Nom",
              textController: _nomController,
            ),
            SimpleTextField(
              label: "Prénoms",
              textController: _prenomController,
            ),
            CustomDropDownField(
              items: Sexe.values.map((e) => e.label).toList(),
              onChanged: (value) {
                setState(() {
                  sexe = Sexe.values.firstWhere((s) => s.label == value);
                });
              },
              label: "Sexe",
              selectedItem: sexe?.label,
            ),
            FutureCustomDropDownField<PaysModel>(
              label: "Pays",
              showSearchBox: true,
              selectedItem: _selectedCountry,
              fetchItems: fetchCountryItems,
              onChanged: (PaysModel? value) {
                if (value != null) {
                  setState(() {
                    _selectedCountry = value;
                  });
                }
              },
              canClose: false,
              itemsAsString: (s) => s.name,
            ),
            TelephoneTextField(
              label: "Téléphone",
              maxLength:
                  _selectedCountry == null ? 1 : _selectedCountry!.phoneNumber!,
              textController: _telephoneController,
              contryCode: _selectedCountry == null
                  ? ""
                  : _selectedCountry!.code.toString(),
            ),
            SimpleTextField(
              label: "Email",
              textController: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            CustomDropDownField(
              items: SituationMatrimoniale.values.map((e) => e).toList(),
              onChanged: (value) {
                setState(() {
                  situationMatrimoniale = value;
                });
              },
              label: "Situation Matrimoniale",
              itemsAsString: (SituationMatrimoniale p0) => p0.label,
              selectedItem: situationMatrimoniale,
            ),
            SimpleTextField(
              label: "Adresse",
              textController: _adresseController,
              keyboardType: TextInputType.text,
              expands: true,
              maxLines: null,
              height: 50,
            ),
            FutureCustomDropDownField<PosteModel>(
              label: "Poste",
              showSearchBox: true,
              selectedItem: _selectedPoste,
              fetchItems: fetchPosteItems,
              onChanged: (PosteModel? value) {
                if (value != null) {
                  setState(() {
                    _selectedPoste = value;
                  });
                }
              },
              canClose: false,
              itemsAsString: (s) => s.libelle,
            ),
            DateField(
              label: "Date de naissance",
              dateController: _dateNaissanceController,
              required: true,
              firstDate: DateTime(1900),
              lastDate: DateTime(
                DateTime.now().year - 15,
                DateTime.now().month,
                DateTime.now().day,
              ),
              onCompleteDate: (DateTime? date) {
                setState(() {
                  _dateNaissanceController.text = getStringDate(time: date!);
                  dateNaissance = date;
                });
              },
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: SimpleTextField(
                    label: "Nombre d'enfants",
                    textController: _nombreEnfantController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                if (!isMobile)
                  Expanded(
                    child: SimpleTextField(
                      label: "Nombre de personnes en charge",
                      textController: _nombrePersonneChargeController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
              ],
            ),
            if (isMobile)
              SimpleTextField(
                label: "Nombre de personnes en charge",
                textController: _nombrePersonneChargeController,
                keyboardType: TextInputType.number,
              ),
            CustomDropDownField(
              items: TypePersonnel.values,
              onChanged: (value) {
                setState(() {
                  typePersonnel = value;
                  typeContrat = null;
                });
              },
              selectedItem: typePersonnel,
              label: "Type de personnel",
              itemsAsString: (TypePersonnel p0) => p0.label,
            ),
            CustomDropDownField(
              items: typePersonnel == null
                  ? []
                  : getContratsFor(type: typePersonnel!),
              onChanged: (value) {
                setState(() {
                  typeContrat = value;
                  if (typeContrat == TypeContrat.cdi) {
                    dateFin == null;
                    _dateFinController.clear();
                  }
                });
              },
              selectedItem: typeContrat,
              label: "Type de contrat",
              itemsAsString: (p0) => p0.label,
            ),
            Row(
              children: [
                Expanded(
                  child: DateField(
                    label: "Date de début",
                    dateController: _dateDebutController,
                    required: true,
                    lastDate: dateFin,
                    onCompleteDate: (DateTime? date) {
                      setState(() {
                        _dateDebutController.text = getStringDate(time: date!);
                        dateDebut = date;
                      });
                    },
                  ),
                ),
                if (!isMobile && typeContrat != TypeContrat.cdi)
                  Expanded(
                    child: DateField(
                      label: "Date de fin",
                      dateController: _dateFinController,
                      required: false,
                      firstDate: dateDebut,
                      onCompleteDate: (DateTime? date) {
                        setState(() {
                          dateFin = date;
                          _dateFinController.text = getStringDate(time: date!);
                        });
                      },
                    ),
                  ),
              ],
            ),
            if (isMobile && typeContrat != TypeContrat.cdi)
              DateField(
                label: "Date de fin",
                dateController: _dateFinController,
                required: false,
                firstDate: dateDebut,
                onCompleteDate: (date) {
                  setState(() {
                    dateFin = date;
                    _dateFinController.text = getStringDate(time: date!);
                  });
                },
              ),
            SimpleTextField(
              label: "Période d'essai (mois)",
              textController: _dureeEssaiController,
              keyboardType: TextInputType.number,
              required: false,
            ),
            SimpleTextField(
              label: "Commentaire",
              textController: _commentaireController,
              expands: true,
              maxLines: null,
              height: 80,
              required: false,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Personnel à preprenir",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SimpleTextField(
              label: "Nom et prénoms",
              textController: _nomPersonnePrevenirController,
            ),
            SimpleTextField(
              label: "Lien d'affiliation",
              textController: _lienController,
            ),
            Row(
              children: [
                Expanded(
                  child: TelephoneTextField(
                    label: "Téléphone 1",
                    maxLength: _selectedCountry == null
                        ? 1
                        : _selectedCountry!.phoneNumber!,
                    textController: _telephone1Controller,
                    contryCode: _selectedCountry == null
                        ? ""
                        : _selectedCountry!.code.toString(),
                  ),
                ),
                if (!isMobile)
                  Expanded(
                    child: TelephoneTextField(
                      label: "Téléphone 2",
                      required: false,
                      maxLength: _selectedCountry == null
                          ? 1
                          : _selectedCountry!.phoneNumber!,
                      textController: _telephone2Controller,
                      contryCode: _selectedCountry == null
                          ? ""
                          : _selectedCountry!.code.toString(),
                    ),
                  ),
              ],
            ),
            if (isMobile)
              TelephoneTextField(
                label: "Téléphone 2",
                required: false,
                maxLength: _selectedCountry == null
                    ? 1
                    : _selectedCountry!.phoneNumber!,
                textController: _telephone2Controller,
                contryCode: _selectedCountry == null
                    ? ""
                    : _selectedCountry!.code.toString(),
              ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () {
                    updatePersonnel(
                      personnel: widget.personnel,
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

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _commentaireController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _dateNaissanceController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    _nombreEnfantController.dispose();
    _nombrePersonneChargeController.dispose();
    _nomPersonnePrevenirController.dispose();
    _lienController.dispose();
    _telephone1Controller.dispose();
    _telephone2Controller.dispose();
    super.dispose();
  }
}
