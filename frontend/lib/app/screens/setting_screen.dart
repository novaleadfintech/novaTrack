import 'package:flutter/material.dart';
import 'package:frontend/app/pages/error_page.dart';
import 'package:frontend/app/responsitvity/responsivity.dart';
 import '../../model/habilitation/role_model.dart';
import '../../service/user_service.dart';
import '../pages/app_dialog_box.dart';
import '../pages/personnel/more_detail_personnel.dart';
import '../../model/personnel/personnel_model.dart';
import '../../service/personnel_service.dart';
import '../../auth/authentification_token.dart';
import '../../model/habilitation/user_model.dart';
import '../../style/app_color.dart';
import 'package:gap/gap.dart';
import '../pages/utilisation/edit_login_parameter.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  UserModel? user;
  late RoleModel role;

  PersonnelModel? personnel;

  Future<void> getUser() async {
    UserModel? utilisation = await AuthService().decodeToken();
    role = await AuthService().getRole();
    user = await UserService.getUser(key: utilisation!.id!);
    if (user != null && user!.personnel != null) {
      personnel = await PersonnelService.getPersonnel(key: user!.personnel!.id);
    }
  }

  void editLoginParametter() {
    showResponsiveDialog(
      context,
      content: EditLoginParametter(refresh: getUser),
      title: "Modifier les données de connexion",
    );
  }

  String getInitials() {
    if (personnel == null) return "";
    return "${personnel!.nom[0]}${personnel!.prenom[0]}".toUpperCase();
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || user == null || personnel == null) {
          return Center(
            child: ErrorPage(
                message: snapshot.error.toString(),
                onPressed: () {
                  setState(() {});
                }),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Header user
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        child: Text(
                          getInitials(),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Gap(12),
                      Text(
                        "${personnel!.nom} ${personnel!.prenom}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Gap(4),
                      Text(
                        role.libelle,
                            style: TextStyle(
                              color: AppColor.grayColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const Gap(24),

              /// Infos personnelles
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                tileColor: Theme.of(context).colorScheme.surface,
                onTap: () {
                  showResponsiveDialog(
                    context,
                    content: SingleChildScrollView(
                      child: MoreDatailPersonnelPage(personnel: personnel!),
                    ),
                    title: "Information personnelle",
                  );
                },
                leading: const Icon(Icons.person_outline),
                title: const Text("Information personnelle"),
                trailing: const Icon(Icons.chevron_right),
              ),

              const Gap(24),

              /// Identifiants
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.login),
                        title: Responsive.isMobile(context)
                            ? null
                            : const Text("Identifiant"),
                        trailing: Text(user!.login ?? ''),
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: Responsive.isMobile(context)
                            ? null
                            : const Text("Mot de passe"),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          ...List.generate(
                            5,
                            (index) => const Icon(Icons.circle, size: 8),
                          ),
                          Gap(8),
                          TextButton(
                              onPressed: editLoginParametter,
                            child: Text(
                              "Modifier",
                            ),
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
