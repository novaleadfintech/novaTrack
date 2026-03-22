import 'package:flutter/material.dart';
import '../../../model/bulletin_paie/categorie_bulletin.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';

class DetailCategorieBulletinPage extends StatefulWidget {
  final CategorieBulletinModel categorieBulletin;
  const DetailCategorieBulletinPage({
    super.key,
    required this.categorieBulletin,
  });

  @override
  State<DetailCategorieBulletinPage> createState() =>
      _DetailCategorieBulletinPageState();
}

class _DetailCategorieBulletinPageState
    extends State<DetailCategorieBulletinPage> {
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
              valeur: widget.categorieBulletin.categorieBulletin,
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
                valeur: widget.categorieBulletin.paieClause.label
            ),
          ],
        ),
      ],
    );
  }
}
