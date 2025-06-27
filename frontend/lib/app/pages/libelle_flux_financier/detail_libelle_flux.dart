import 'package:flutter/material.dart';
import '../../../model/flux_financier/libelle_flux.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';

class DetailFluxPage extends StatefulWidget {
  final LibelleFluxModel libelleFlux;
  const DetailFluxPage({
    super.key,
    required this.libelleFlux,
  });

  @override
  State<DetailFluxPage> createState() => _DetailFluxPageState();
}

class _DetailFluxPageState extends State<DetailFluxPage> {
  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Libellé",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.libelleFlux.libelle,
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Type",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.libelleFlux.type.label,
            ),
          ],
        ),
      ],
    );
  }
}
