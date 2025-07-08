import 'package:flutter/material.dart';
import 'package:frontend/model/personnel/poste_model.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';

class DetailPostePage extends StatefulWidget {
  final PosteModel poste;
  const DetailPostePage({
    super.key,
    required this.poste,
  });

  @override
  State<DetailPostePage> createState() => _DetailPostePageState();
}

class _DetailPostePageState extends State<DetailPostePage> {
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
              valeur: widget.poste.libelle,
            ),
          ],
        ),
      ],
    );
  }
}
