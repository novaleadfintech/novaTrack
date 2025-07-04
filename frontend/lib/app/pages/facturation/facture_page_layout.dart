import 'package:flutter/material.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../app_tab_bar.dart';
import '../error_page.dart';
import 'archive_facture/archive_facture_page.dart';
import 'facture/facture_page.dart';
import 'proforma/proformat_page.dart';
import '../../../model/facturation/enum_facture.dart';
import 'recurrent/facture_recurent_page.dart';

class FacturePageLayout extends StatefulWidget {
  
  const FacturePageLayout({super.key});

  @override
  State<FacturePageLayout> createState() => _FacturePageState();
}

class _FacturePageState extends State<FacturePageLayout> {
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
                EtatFacture.proformat.label,
                EtatFacture.facture.label,
                "Archives",
                "Récurrence",
              ],
              views: [
                ProformaPage(role: role),
                FacturePage(role: role),
                ArchiveFacturePage(
                  role: role,
                ),
                FactureRecurrentePage(
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
