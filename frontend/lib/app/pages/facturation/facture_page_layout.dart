import 'package:flutter/material.dart';
import '../app_tab_bar.dart';
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

  @override
  Widget build(BuildContext context) {
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
                ProformaPage(),
                FacturePage(),
                ArchiveFacturePage(),
                FactureRecurrentePage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
