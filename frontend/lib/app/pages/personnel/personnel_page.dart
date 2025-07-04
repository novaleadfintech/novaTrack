import 'package:flutter/material.dart';
import 'package:frontend/model/personnel/enum_personnel.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../app_tab_bar.dart';
import '../error_page.dart';
import 'archived_personnel_page.dart';
import 'unarchived_personnel_page.dart';

class PersonnelPage extends StatefulWidget {
  const PersonnelPage({super.key});

  @override
  State<PersonnelPage> createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<PersonnelPage> {
  late RoleModel role;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  Future<void> _initializeData() async {
    await getRole();
  }

  Future<void> getRole() async {
    try {
      setState(() {
        isLoading = true;
      });
      role = await AuthService().getRole();
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return ErrorPage(
        message: errorMessage ?? "Une erreur s'est produite",
        onPressed: () async {
          setState(() {
            isLoading = true;
            hasError = false;
          });
          await getRole();
        },
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 0, left: 8, right: 8),
      child: Column(
        children: [
          Expanded(
            child: AppTabBar(
              tabTitles: [
                EtatPersonnel.unarchived.label,
                EtatPersonnel.archived.label,
              ],
              views:  [
                UnarchivedPersonnelPage(role: role),
                ArchivedPersonnelPage(role: role),
              ],
            ),
          )
        ],
      ),
    );
  }
}
