import 'package:flutter/material.dart';
 import '../../../../model/grille_salariale/classe_model.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';

class DetailClassePage extends StatefulWidget {
  final ClasseModel classe;
  const DetailClassePage({
    super.key,
    required this.classe,
  });

  @override
  State<DetailClassePage> createState() => _DetailClassePageState();
}

class _DetailClassePageState extends State<DetailClassePage> {
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
              valeur: widget.classe.libelle,
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "les échelons",
              isbold: true,
            ),
            Column(
              children: [
                ...widget.classe.echelonIndiciciaires!.map(
                    (e) => TabledetailBodyMiddle(valeur: e.echelon.libelle))
              ],
            )
          ],
        ),
      ],
    );
  }
}
