import 'package:flutter/material.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../app_tab_bar.dart';
import '../error_page.dart';
import 'archive_page.dart';
import 'bilan_page.dart';
import 'input_page.dart';
import 'output_page.dart';

import '../../../model/flux_financier/type_flux_financier.dart';
import 'validation_page.dart';

class FluxFinancierLayout extends StatefulWidget {
  const FluxFinancierLayout({super.key});

  @override
  State<FluxFinancierLayout> createState() => _FacturePageState();
}

class _FacturePageState extends State<FluxFinancierLayout> {

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
  List<String> tabbarTiles = [
    FluxFinancierType.input.label,
    FluxFinancierType.output.label,
    "Validation",
    "Brouillard",
    "Archives",
  ];
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
    return Column(
      children: [
        Expanded(
          child: AppTabBar(
            tabTitles: tabbarTiles,
            views: [
              InputPage(role: role),
              OutputPage(role: role),
              ValidationPage(role: role),
              BilanPage(),
              ArchivesPage(role: role),
            ],
          ),
        )
      ],
    );
  }
}
