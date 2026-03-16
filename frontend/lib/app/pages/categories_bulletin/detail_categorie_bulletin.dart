import 'package:flutter/material.dart';
import '../../../model/bulletin_paie/categorie_paie.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';

class DetailCategoriePaiePage extends StatefulWidget {
  final CategoriePaieModel categorie;
  const DetailCategoriePaiePage({
    super.key,
    required this.categorie,
  });

  @override
  State<DetailCategoriePaiePage> createState() =>
      _DetailCategoriePaiePageState();
}

class _DetailCategoriePaiePageState extends State<DetailCategoriePaiePage> {
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
              valeur: widget.categorie.categoriePaie,
            ),
          ],
        ),
      ],
    );
  }
}
