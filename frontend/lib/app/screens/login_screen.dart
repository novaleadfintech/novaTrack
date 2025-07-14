import 'package:flutter/material.dart';
import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/style/app_color.dart';
import '../../helper/user_helper.dart';
import '../../model/habilitation/role_enum.dart';
import '../../model/habilitation/role_model.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../auth/authentification_token.dart';
import '../../service/user_service.dart';
import '../../widget/validate_button.dart';
import '../integration/request_frot_behavior.dart';
import '../../style/app_style.dart';
import '../../widget/password_textfield.dart';
import '../../widget/simple_text_field.dart';
import '../pages/utilisation/edit_login_parameter.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final SimpleFontelicoProgressDialog _dialog;
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez renseigner l'identifiant et le mot de passe",
      );
      return;
    }

    _dialog.show(
      message: '',
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      final result = await UserService.seConnecter(
        login: login,
        password: password,
      );

      _dialog.hide();

      AuthService().setToken(result.token!);
      try {
        final role = getRoleSwitchAutorization(
                roleAuthorization: RoleAuthorization.accepted,
                roles: result.roles!)!
            .role;

        AuthService().setRoles(role);
        if (result.isTheFirstConnection == true) {
          openEditLoginParameter();
          return;
        }
        _navigateToMainLayout(role);
      } catch (e) {
        _dialog.hide();
        MutationRequestContextualBehavior.showPopup(
          customMessage:
              "Vous n'êtes pas encore autorisé faire une action dans ce application.",
          status: PopupStatus.serverError,
        );
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        customMessage: "Échec de la connexion : $e",
        status: PopupStatus.serverError,
      );
    }
  }

  openEditLoginParameter() {
    showResponsiveDialog(
      context,
      content: EditLoginParametter(
        refresh: () async {},
      ),
      title: "Modifier votre mot de passe",
    );
  }

  void _navigateToMainLayout(RoleModel role) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainLayout(role: role),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Ne pas bouger le layout quand le clavier sort
      backgroundColor: AppColor.adaptativeLoginScreenBachroundColor(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            // Permet de scroller sous le clavier manuellement
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Pour éviter que le clavier cache
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(50),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/logo.jpg",
                        width: 40,
                      ),
                      const Gap(8),
                      Text(
                        "Connectez-vous",
                        style: DestopAppStyle.titleText.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(8),
                      Form(
                        child: Column(children: [
                          SimpleTextField(
                            textController: _loginController,
                            label: "Identifiant",
                            putUniqueKey: false,
                          ),
                          PasswordTextField(
                            controller: _passwordController,
                            label: "Mot de passe",
                          ),
                          const Gap(12),
                          SizedBox(
                            height: 40,
                            width: double.infinity,
                            child: ValidateButton(
                              onPressed: login,
                              libelle: "Connexion",
                            ),
                          ),
                        ]),
                      )
                    ],
                  ),
                ),
                const Gap(50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
