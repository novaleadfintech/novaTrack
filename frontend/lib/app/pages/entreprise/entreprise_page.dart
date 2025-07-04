import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/app/pages/error_page.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:frontend/style/app_color.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../auth/authentification_token.dart';
import '../../../helper/telephone_number_helper.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../model/pays_model.dart';
import '../../../model/entreprise/entreprise.dart';
import '../../../model/request_response.dart';
import '../../../service/entreprise_service.dart';
import '../../../service/pays_service.dart';
import '../../../widget/file_field.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/telephone_field.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class EntreprisePage extends StatefulWidget {
  final RoleModel role;
  const EntreprisePage({
    super.key,
    required this.role,
  });

  @override
  State<EntreprisePage> createState() => _EntreprisePageState();
}

class _EntreprisePageState extends State<EntreprisePage> {
  final _formKey = GlobalKey<FormState>();
  bool isEditable = false;
  bool isLoading = true;
  late SimpleFontelicoProgressDialog _dialog;

  late TextEditingController nameController;
  late TextEditingController adresseController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController nomDGController;
  late TextEditingController villeController;
  String? errormessage;
  PlatformFile? logoFile;
  PlatformFile? tamponFile;
  PaysModel? _selectedCountry;
  Entreprise? entreprise;
  late RoleModel role;

  @override
  void initState() {
    nameController = TextEditingController();
    adresseController = TextEditingController();
    emailController = TextEditingController();
    telephoneController = TextEditingController();
    nomDGController = TextEditingController();
    villeController = TextEditingController();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    role = widget.role;
    _loadEntreprise();
    super.initState();
  }

  Future<void> _loadEntreprise() async {
    try {
      setState(() => isLoading = true);
      entreprise = await EntrepriseService.getEntrepriseInformationForUpdate();
      if (entreprise != null) {
        _populateFormData();
      }
    } catch (err) {
      errormessage = err.toString();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  Future<List<PaysModel>> fetchCountryItems() async {
    return await PaysService.getAllPays();
  }

  void _populateFormData() {
    setState(() {
      nameController.text = entreprise!.raisonSociale ?? '';
      adresseController.text = entreprise!.adresse ?? '';
      emailController.text = entreprise!.email ?? '';
      telephoneController.text = entreprise!.telephone?.toString() ?? '';
      nomDGController.text = entreprise!.nomDG ?? '';
      villeController.text = entreprise!.ville ?? '';
      logoFile = entreprise!.logo != null
          ? PlatformFile(
              path: entreprise!.logo,
              size: 10,
              name: entreprise!.logo!.split('/').last)
          : null;
      tamponFile = entreprise!.tamponSignature != null
          ? PlatformFile(
              path: entreprise!.tamponSignature!,
              size: 10,
              name: entreprise!.tamponSignature!.split('/').last)
          : null;
    });
    _selectedCountry = entreprise!.pays;
  }

  @override
  void dispose() {
    nameController.clear();
    adresseController.clear();
    emailController.clear();
    telephoneController.clear();
    nomDGController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isEditable = hasPermission(
        role: role, permission: PermissionAlias.manageEntreprise.label);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          color: AppColor.whiteColor,
          child: Form(
            key: UniqueKey(),
            child: Column(
              children: [
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : errormessage != null
                          ? ErrorPage(
                              message: errormessage ??
                                  "Erreur lors de la recupération des données",
                              onPressed: _loadEntreprise,
                            )
                          : SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FileField(
                                      canTakePhoto: false,
                                      label: "Logo",
                                      platformFile: logoFile,
                                      removeFile: () => setState(() {
                                        logoFile = null;
                                      }),
                                      canBePdf: false,
                                      pickFile: (file) {
                                        setState(() {
                                          logoFile = file;
                                        });
                                      },
                                    ),
                                    Gap(8),
                                    FileField(
                                      canTakePhoto: false,
                                      label: "Tampon et signature",
                                      platformFile: tamponFile,
                                      removeFile: () => setState(() {
                                        tamponFile = null;
                                      }),
                                      canBePdf: false,
                                      pickFile: (file) {
                                        setState(() {
                                          tamponFile = file;
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
                                      label: 'Ville',
                                      textController: villeController,
                                      readOnly: !isEditable,
                                    ),
                                    SimpleTextField(
                                      label: 'Raison sociale',
                                      textController: nameController,
                                      readOnly: !isEditable,
                                    ),
                                    SimpleTextField(
                                      label: 'Email',
                                      textController: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      readOnly: !isEditable,
                                    ),
                                    TelephoneTextField(
                                      readOnly: !isEditable,
                                      label: "Téléphone",
                                      textController: telephoneController,
                                      contryCode: _selectedCountry == null
                                          ? ""
                                          : _selectedCountry!.code.toString(),
                                      maxLength: _selectedCountry == null
                                          ? 1
                                          : _selectedCountry!.phoneNumber ?? 1,
                                    ),
                                    SimpleTextField(
                                      label: 'Nom du DG',
                                      textController: nomDGController,
                                      readOnly: !isEditable,
                                    ),
                                    SimpleTextField(
                                      label: 'Adresse',
                                      textController: adresseController,
                                      maxLines: 3,
                                      // keyboardType: TextInputType.multiline,
                                      // textInputAction:
                                      //     TextInputAction.newline,
                                      height: 100,
                                      readOnly: !isEditable,
                                    ),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed:
                                            isEditable ? _saveChanges : null,
                                        child: const Text('Enregistrer'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    if (entreprise == null) {
      return;
    }
    if (adresseController.text.isEmpty ||
        emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        telephoneController.text.isEmpty ||
        nomDGController.text.isEmpty ||
        _selectedCountry == null ||
        villeController.text.isEmpty ||
        tamponFile == null ||
        logoFile == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez renseigner tous les champs marqués *",
      );
      return;
    }
    var err = checkPhoneNumber(
      phoneNumber: telephoneController.text.trim(),
      pays: _selectedCountry!,
    );
    if (err != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: err.toString(),
      );
      return;
    }

    _dialog.show(
        message: "Enregistrement en cours...",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent);

    try {
      RequestResponse result = await EntrepriseService.updateEntreprise(
        key: entreprise!.id,
        adresse: adresseController.text.trim().isEmpty
            ? null
            : adresseController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        telephone: int.tryParse(telephoneController.text.trim()),
        nomDG: nomDGController.text.trim().isEmpty
            ? null
            : nomDGController.text.trim(),
        ville: villeController.text.trim().isEmpty
            ? null
            : villeController.text.trim(),
        pays: _selectedCountry,
        logo: logoFile!.bytes == null ? null : logoFile,
        raisonSociale: nameController.text.trim().isEmpty
            ? null
            : nameController.text.trim(),
        tamponSignature: tamponFile!.bytes == null ? null : tamponFile,
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Données sauvegardées avec succès",
        );
        // await _loadEntreprise();
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
        customMessage: "erreur lors de l'enregistrement des données: $err",
      );
    }
  }
}
