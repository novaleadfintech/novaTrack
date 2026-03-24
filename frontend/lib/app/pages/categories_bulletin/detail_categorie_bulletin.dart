import 'package:flutter/material.dart';
import '../../../model/bulletin_paie/bulletin_categorie.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';

class DetailBulletinCategoriePage extends StatefulWidget {
  final BulletinCategorieModel bulletinCategorie;
  const DetailBulletinCategoriePage({
    super.key,
    required this.bulletinCategorie,
  });

  @override
  State<DetailBulletinCategoriePage> createState() =>
      _DetailBulletinCategoriePageState();
}

class _DetailBulletinCategoriePageState
    extends State<DetailBulletinCategoriePage> {
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
              valeur: widget.bulletinCategorie.bulletinCategorie,
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Clause de paie",
              isbold: true,
            ),
            TabledetailBodyMiddle(
                valeur: widget.bulletinCategorie.paieClause.label
            ),
          ],
        ),
      ],
    );
  }
}
