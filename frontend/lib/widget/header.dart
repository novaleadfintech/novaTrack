import 'package:flutter/material.dart';
import 'package:frontend/helper/string_helper.dart';
import '../app/pages/app_dialog_box.dart';
import '../app/screens/login_screen.dart';
import '../app/screens/setting_screen.dart';
import '../auth/authentification_token.dart';
import '../model/habilitation/role_enum.dart';
import '../model/habilitation/user_model.dart';
import '../style/app_color.dart';
import 'app_menu_popup.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../service/user_service.dart';
import '../style/app_style.dart';
import '../app/responsitvity/responsivity.dart';

class Header extends StatefulWidget {
  final String title;
  const Header({
    super.key,
    required this.title,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late SimpleFontelicoProgressDialog _dialog;

  String userName = "Prenom";
  UserModel? user;
  bool isLoading = false;
  @override
  void initState() {
    getUserName();
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> getUserName() async {
    try {
      user = await AuthService().decodeToken();
      if (user != null) {
        setState(() {
          userName = user!.personnel!.prenom;
          isLoading = false; // Les données sont chargées
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  onselected(String value) async {
    switch (value) {
      case "Déconnexion":
        if (user != null) {
          await onSelectionDeconnnexion();
        }
        break;
      case "Paramètre":
        if (user != null) {
          await onSelectionParametre();
        }
        break;
    }
  }

  onSelectionParametre() {
    Responsive.isMobile(context)
        ? Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                backgroundColor: AppColor.whiteColor,
                appBar: AppBar(
                  title: Text("Utilisateur"),
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: AppColor.whiteColor,
                ),
                body: SettingScreen(),
              ),
            ),
          )
        : showResponsiveDialog(
            context,
            content: const SettingScreen(),
            title: "Utilisateur",
          );
  }

  onSelectionDeconnnexion() async {
    _dialog.show(
      message: '',
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    AuthService().clearToken();

    // RequestResponse result =
    await UserService.seDeconnecter(userId: user!.id!);
    AuthService().clearToken();
    _dialog.hide();
    // if (result.status == PopupStatus.success) {
    callLoginPage();
    // } else {
    // callLoginPage();
    // }
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
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.title,
                style: Responsive.isDesktop(context)
                    ? DestopAppStyle.bigTitleText.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : DestopAppStyle.titleText.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            CustomPopupMenu(
              tooltip: "Option de compte",
              onSelected: (value) async {
                await onselected(value);
              },
              items: const [
                (value: "Paramètre", color: null),
                (value: "Déconnexion", color: null),
              ],
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColor.dirtyWhite,
                    child: Icon(
                      Icons.person,
                      color: AppColor.blackColor,
                    ),
                  ),
                  if (Responsive.isDesktop(context)) ...[
                    const Gap(4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                userName,
                                style: DestopAppStyle.normalText.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                        if (!isLoading && user != null)
                          Text(
                            "(${capitalizeFirstLetter(word: user!.roles!.firstWhere((userRole) {
                                  return userRole.roleAuthorization ==
                                      RoleAuthorization.accepted;
                                }).role.libelle)})",
                            style: DestopAppStyle.normalText.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
