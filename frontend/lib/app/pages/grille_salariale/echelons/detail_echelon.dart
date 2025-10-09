import 'package:flutter/material.dart';
import '../../../../model/grille_salariale/echelon_model.dart';
 import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';

class DetailEchelonPage extends StatefulWidget {
  final EchelonModel echelon;
  const DetailEchelonPage({
    super.key,
    required this.echelon,
  });

  @override
  State<DetailEchelonPage> createState() => _DetailEchelonPageState();
}

class _DetailEchelonPageState extends State<DetailEchelonPage> {
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
              valeur: widget.echelon.libelle,
            ),
          ],
        ),
      ],
    );
  }
}
