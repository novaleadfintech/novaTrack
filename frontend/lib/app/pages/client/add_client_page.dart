import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/client/responsable_model.dart';
import 'package:frontend/model/request_response.dart';
import 'package:frontend/service/pays_service.dart';
import 'package:frontend/style/app_color.dart';
import '../../../helper/telephone_number_helper.dart';
import '../../../service/categorie_service.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../model/client/categorie_model.dart';
import '../../../model/client/enum_client.dart';
import '../../../model/pays_model.dart';
import '../../../service/client_service.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/file_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/telephone_field.dart';
import '../../../widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/common_type.dart';

class AddClientPage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddClientPage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _raisonSocialeController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _responsableNomController =
      TextEditingController();
  final TextEditingController _responsablePrenomControlller =
      TextEditingController();
  final TextEditingController _responsableEmailController =
      TextEditingController();
  final TextEditingController _responsableTelephoneController =
      TextEditingController();
  final TextEditingController _responsablePosteController =
      TextEditingController();
  //final List<Map<String, dynamic>> _agenceControllers = [];

  TypeClient type = TypeClient.moral;
  NatureClient nature = NatureClient.client;
  Sexe? sexe;
  Civilite? responsableCivilite;
  CategorieModel? categorie;
  Sexe? responsableSexe;
  PlatformFile? file;
  PaysModel? _selectedCountry;
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  String? validateClientFields() {
    if (_selectedCountry == null) {
      return "Veuillez remplir tous les champs marqués.";
    }

    if (nature != NatureClient.fournisseur) {
      if (_telephoneController.text.isEmpty ||
          _adresseController.text.isEmpty ||
          _emailController.text.isEmpty) {
        return "Veuillez remplir tous les champs marqués.";
      }
    }

    if (type == TypeClient.moral) {
      if (_raisonSocialeController.text.isEmpty || categorie == null) {
        return "Veuillez remplir tous les champs marqués.";
      }

      if (nature != NatureClient.fournisseur) {
        if (_responsableEmailController.text.isEmpty ||
            _responsableNomController.text.isEmpty ||
            _responsablePosteController.text.isEmpty ||
            _responsablePrenomControlller.text.isEmpty ||
            _responsableTelephoneController.text.isEmpty ||
            responsableSexe == null ||
            responsableCivilite == null ||
            file == null) {
          return "Veuillez remplir tous les champs marqués.";
        }
      }
    } else {
      if (_nomController.text.isEmpty ||
          _prenomController.text.isEmpty ||
          sexe == null) {
        return "Veuillez remplir tous les champs marqués.";
      }
    }

    return null;
  }

  Future<void> _addClient() async {
    try {
      if (nature == NatureClient.fournisseur) {
        _responsableEmailController.clear();
        _responsableNomController.clear();
        _responsablePosteController.clear();
        _responsablePrenomControlller.clear();
        _responsableTelephoneController.clear();
        responsableSexe == null;
        responsableCivilite == null;
        _responsableEmailController.clear();
        _responsableTelephoneController.clear();
      }

    String? errMessage = validateClientFields();
      if (_telephoneController.text.trim().isNotEmpty) {
        errMessage ??= checkPhoneNumber(
          phoneNumber: _telephoneController.text.trim(),
          pays: _selectedCountry!,
        );
      }
      if (_responsableTelephoneController.text.trim().isNotEmpty) {
        if (errMessage == null) {
          if (type == TypeClient.moral) {
            errMessage = checkPhoneNumber(
              phoneNumber: _responsableTelephoneController.text.trim(),
              pays: _selectedCountry!,
            );
          }
        }
      }
    if (errMessage != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: errMessage,
      );
      return;
    }
    
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
ResponsableModel? buildResponsable() {
        try {
          return ResponsableModel(
            prenom: _responsablePrenomControlller.text,
            nom: _responsableNomController.text,
            sexe: responsableSexe!,
            civilite: responsableCivilite!,
            email: _responsableEmailController.text,
            telephone: int.parse(_responsableTelephoneController.text),
            poste: _responsablePosteController.text,
          );
        } catch (e) {
          if (nature != NatureClient.fournisseur) {
            throw "Revérifiez les données du responsable et reessayez";
          }
          return null;
        }
      }

      RequestResponse result = type == TypeClient.moral
          ? await ClientService.createMoralClient(
              nature: nature,
              raisonSociale: _raisonSocialeController.text.trim(),
              responsable: buildResponsable(),
            categorieId: categorie!.id,
              email: _emailController.text.trim(),
              telephone: int.tryParse(_telephoneController.text.trim()),
              adresse: _adresseController.text.trim(),
              file: file,
            pays: _selectedCountry!,
          )
        : await ClientService.createPhysiqueClient(
              nom: _nomController.text.trim(),
              prenom: _prenomController.text.trim(),
            sexe: sexe!,
            nature: nature,
              email: _emailController.text.trim(),
              telephone: int.parse(_telephoneController.text.trim()),
              adresse: _adresseController.text.trim(),
            pays: _selectedCountry!);

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Le partenaire a été crée avec succès",
      );
      await widget.refresh();
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

  Future<List<PaysModel>> fetchCountryItems() async {
    return await PaysService.getAllPays();
  }

  @override
  Widget build(BuildContext context) {
    bool isNotFournisseur = !(nature == NatureClient.fournisseur);
    return SingleChildScrollView(
      child: Form(
        //key: UniqueKey(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropDownField<TypeClient>(
              items: TypeClient.values.toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                  });
                }
              },
              label: "Type",
              selectedItem: type,
              itemsAsString: (p0) => p0.label,
            ),
            CustomDropDownField<NatureClient>(
              items: NatureClient.values.toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    nature = value;
                  });
                }
              },
              label: "Nature",
              selectedItem: nature,
              itemsAsString: (p0) => p0.label,
            ),
            if (type == TypeClient.physique)
              PhysiqueFields(
                nomController: _nomController,
                prenomController: _prenomController,
                sexe: sexe,
                onSexeChanged: (newSexe) {
                  setState(() {
                    sexe = newSexe;
                  });
                },
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
            SimpleTextField(
              label: "Email",
              textController: _emailController,
              required: isNotFournisseur,
              keyboardType: TextInputType.emailAddress,
            ),
            TelephoneTextField(
              label: "Téléphone",
              maxLength:
                  _selectedCountry == null ? 1 : _selectedCountry!.phoneNumber!,
              textController: _telephoneController,
              required: isNotFournisseur,
              contryCode: _selectedCountry == null
                  ? ""
                  : _selectedCountry!.code.toString(),
            ),
            SimpleTextField(
              label: "Adresse",
              textController: _adresseController,
              expands: true,
              required: isNotFournisseur,
              maxLines: null,
              height: 50,
            ),
            /* AgencesFields(
              controllers: _agenceControllers,
            ), */
            if (type == TypeClient.moral) ...[
              FileField(
                canTakePhoto: false,
                label: "Logo",
                required: isNotFournisseur,
                platformFile: file,
                removeFile: () => setState(() {
                  file = null;
                }),
                canBePdf: false,
                pickFile: (p0) {
                  setState(() {
                    file = p0;
                  });
                },
              ),
              MoralFields(
                categorie: categorie,
                onCategorieChanged: (newCategorie) {
                  setState(() {
                    categorie = newCategorie;
                  });
                },
                raisonSocialeController: _raisonSocialeController,
                responsableEmailController: _responsableEmailController,
                isNotFournisseur: isNotFournisseur,
                onResponsableCiviliteChanged: (newCivilite) {
                  setState(() {
                    responsableCivilite = newCivilite;
                  });
                },
                onResponsableSexeChanged: (newSexe) {
                  setState(() {
                    responsableSexe = newSexe;
                  });
                },
                country: _selectedCountry,
                responsableNomController: _responsableNomController,
                responsablePosteController: _responsablePosteController,
                responsablePrenomControlller: _responsablePrenomControlller,
                responsableTelephoneController: _responsableTelephoneController,
              ),
            ],
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () async {
                    await _addClient();
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

class PhysiqueFields extends StatefulWidget {
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final Sexe? sexe;
  final void Function(Sexe?) onSexeChanged;

  const PhysiqueFields({
    super.key,
    required this.prenomController,
    required this.nomController,
    required this.sexe,
    required this.onSexeChanged,
  });

  @override
  State<PhysiqueFields> createState() => _PhysiqueFieldsState();
}

class _PhysiqueFieldsState extends State<PhysiqueFields> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SimpleTextField(
            label: "Nom",
            textController: widget.nomController,
          ),
          SimpleTextField(
            label: "Prénoms",
            textController: widget.prenomController,
          ),
          CustomDropDownField<Sexe>(
            items: Sexe.values.toList(),
            onChanged: widget.onSexeChanged,
            label: "Sexe",
            selectedItem: widget.sexe,
            itemsAsString: (s) => s.label,
          ),
        ],
      ),
    );
  }
}

class MoralFields extends StatefulWidget {
  final TextEditingController raisonSocialeController;
  final TextEditingController responsableNomController;
  final TextEditingController responsablePrenomControlller;
  final TextEditingController responsableEmailController;
  final TextEditingController responsablePosteController;
  final TextEditingController responsableTelephoneController;
  final CategorieModel? categorie;
  final Sexe? responsableSexe;
  final bool isNotFournisseur;
  final PaysModel? country;
  final Civilite? responsableCivilite;
  final void Function(CategorieModel?) onCategorieChanged;
  final void Function(Sexe?) onResponsableSexeChanged;
  final void Function(Civilite?) onResponsableCiviliteChanged;

  const MoralFields({
    super.key,
    required this.raisonSocialeController,
    required this.responsableEmailController,
    required this.responsableNomController,
    required this.responsablePosteController,
    required this.responsablePrenomControlller,
    required this.isNotFournisseur,
    this.categorie,
    required this.country,
    required this.onCategorieChanged,
    this.responsableSexe,
    required this.onResponsableSexeChanged,
    this.responsableCivilite,
    required this.onResponsableCiviliteChanged,
    required this.responsableTelephoneController,
  });

  @override
  State<MoralFields> createState() => _MoralFieldsState();
}

class _MoralFieldsState extends State<MoralFields> {
  void _handleCategoryChange(CategorieModel? newValue) {
    setState(() {
      widget.onCategorieChanged(newValue);
    });
  }

  void _handleResponsableSexeChange(Sexe? newValue) {
    setState(() {
      widget.onResponsableSexeChanged(newValue);
    });
  }

  void _handleResponsableCiviliteChange(Civilite? newValue) {
    setState(() {
      widget.onResponsableCiviliteChanged(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SimpleTextField(
            label: "Raison sociale",
            textController: widget.raisonSocialeController,
          ),
          FutureCustomDropDownField(
            label: "Catégorie",
            selectedItem: widget.categorie,
            fetchItems: fetchCategorieItems,
            onChanged: _handleCategoryChange,
            itemsAsString: (CategorieModel c) => c.libelle,
          ),
          if (widget.isNotFournisseur) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: AppColor.primaryColor.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Personne contact",
                      style: TextStyle(fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all()),
                child: Column(
                  children: [
                    SimpleTextField(
                      label: "Nom",
                      required: widget.isNotFournisseur,
                      textController: widget.responsableNomController,
                    ),
                    SimpleTextField(
                      label: "Prénoms",
                      textController: widget.responsablePrenomControlller,
                    ),
                    CustomDropDownField<Sexe>(
                      items: Sexe.values.toList(),
                      onChanged: _handleResponsableSexeChange,
                      label: "Sexe",
                      selectedItem: widget.responsableSexe,
                      itemsAsString: (s) => s.label,
                    ),
                    CustomDropDownField<Civilite>(
                      items: Civilite.values.toList(),
                      onChanged: _handleResponsableCiviliteChange,
                      label: "Civilité",
                      selectedItem: widget.responsableCivilite,
                      itemsAsString: (s) => s.label,
                    ),
                    TelephoneTextField(
                      label: "Téléphone",
                      textController: widget.responsableTelephoneController,
                      contryCode: widget.country == null
                          ? ""
                          : widget.country!.code.toString(),
                      maxLength: widget.country == null
                          ? 1
                          : widget.country!.phoneNumber!,
                    ),
                    SimpleTextField(
                      label: "Email",
                      textController: widget.responsableEmailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SimpleTextField(
                      label: "Poste",
                      textController: widget.responsablePosteController,
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Future<List<CategorieModel>> fetchCategorieItems() async {
    return await CategorieService.getCategories();
  }
}
