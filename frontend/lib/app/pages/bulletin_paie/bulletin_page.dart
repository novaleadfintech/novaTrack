import 'package:flutter/material.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../app_tab_bar.dart';
import '../error_page.dart';
import 'archive/archive_bulletin_page.dart';
import 'bulletin/bulletin_page.dart';
import 'decouverte/decouverte_page.dart';
import 'salarie/salaire_page.dart';

class BulletinLayout extends StatefulWidget {
  const BulletinLayout({super.key});

  @override
  State<BulletinLayout> createState() => _BulletinLayoutState();
}

class _BulletinLayoutState extends State<BulletinLayout> {
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
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 0,
        left: 8,
        right: 8,
      ),
      child: Column(
        children: [
          Expanded(
            child: AppTabBar(
              tabTitles: [
                "Salarié",
                "Bulletin",
                "Découvert",
                "Archives",
              ],
              views: [
                SalariePage(),
                BulletinPage(),
                DecouvertePage(role: role),
                ArchiveBulletinPage(
                  role: role,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
