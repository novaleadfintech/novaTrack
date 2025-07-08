import 'package:flutter/material.dart';
import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/model/request_response.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../service/user_service.dart';
import '../../../widget/password_textfield.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/request_frot_behavior.dart';
import '../../screens/login_screen.dart';

class EditLoginParametter extends StatefulWidget {
  final Future<void> Function() refresh;
  const EditLoginParametter({super.key, required this.refresh});

  @override
  State<EditLoginParametter> createState() => _EditLoginParametterState();
}

class _EditLoginParametterState extends State<EditLoginParametter> {
  late SimpleFontelicoProgressDialog _dialog;
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  UserModel? user;
  String? newLogin;
  String? newPassword;
  Future<void> getUser() async {
    user = await AuthService().decodeToken();
    setState(() {
      _loginController.text = user?.login ?? '';
    });
  }

  bool isStrongPassword(String password) {
    final strongPasswordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*\d).{8,}$',
    );
    return strongPasswordRegex.hasMatch(password);
  }

  editLoginParametter() async {
    try {
      String? newLogin;
    String? newPassword;

    // Vérifier si le login a changé
    if (user!.login! != _loginController.text) {
      newLogin = _loginController.text;
    }
    if (_oldPasswordController.text.isEmpty) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir le champs de l'ancien mote de passe.",
      );
      return;
    }
    // Vérifier si le mot de passe a changé
    if (_passwordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Le mot de passe et sa confirmation ne correspondent pas.",
        );
        return;
      } else if (!isStrongPassword(_passwordController.text)) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Le mot de passe doit contenir au moins 8 caractères, "
              "une majuscule, un chiffre et un caractère spécial.",
        );
        return;
      } else if (user!.password! != _passwordController.text) {
        newPassword = _passwordController.text;
      }
    }
    if (newLogin == null && newPassword == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Aucune modification n'a été faite.",
      );
      return;
    }
    _dialog.show(
      message: '',
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    RequestResponse result = await UserService.updateLoginData(
        userId: user!.id!,
        login: newLogin,
        password: newPassword!,
        ancienMotdepasse: _oldPasswordController.text);

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );
      RequestResponse result =
          await UserService.seDeconnecter(userId: user!.id!);
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
        AuthService().clearToken();
        callLoginPage();
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage:
              "Les paramètres de connexion sont mise à jour avec succès. Veuillez à present vous reconnecter avec votre nouveau de passe! ",
        );
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
    } catch (e) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: e.toString(),
      );
    }
  }

  callLoginPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SimpleTextField(
            textController: _loginController,
            readOnly: true,
            label: "Identifiant",
            color: Theme.of(context).colorScheme.secondary,
          ),
          SimpleTextField(
            textController: _oldPasswordController,
            label: "Ancien mot de passe",
            required: false,
          ),
          PasswordTextField(
            controller: _passwordController,
            label: "Nouveau mot de passe",
            required: false,
          ),
          PasswordTextField(
            controller: _confirmPasswordController,
            label: "Confirmer le mot de passe",
            required: false,
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValidateButton(
              onPressed: () async {
                await editLoginParametter();
              },
              libelle: "Valider",
            ),
          ),
        ],
      ),
    );
  }
}
