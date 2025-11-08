import 'package:flutter/material.dart';
import 'package:frontend/model/bulletin_paie/operateur_model.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';

class DetailOperateurPage extends StatefulWidget {
  final OperateurModel operateur;
  const DetailOperateurPage({
    super.key,
    required this.operateur,
  });

  @override
  State<DetailOperateurPage> createState() => _DetailOperateurPageState();
}

class _DetailOperateurPageState extends State<DetailOperateurPage> {
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
              valeur: widget.operateur.libelle,
            ),
          ],
        ),
      ],
    );
  }
}
