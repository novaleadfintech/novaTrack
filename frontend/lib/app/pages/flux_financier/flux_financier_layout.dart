import 'package:flutter/material.dart';
import '../app_tab_bar.dart';
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
  List<String> tabbarTiles = [
    FluxFinancierType.input.label,
    FluxFinancierType.output.label,
    "Validation",
    "Brouillard",
    "Archives",
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AppTabBar(
            tabTitles: tabbarTiles,
            views: const [
              InputPage(),
              OutputPage(),
              ValidationPage(),
              BilanPage(),
              ArchivesPage(),
            ],
          ),
        )
      ],
    );
  }
}
