 import 'package:flutter/material.dart';
 import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../model/grille_salariale/categorie_paie.dart'
    show GrilleCategoriePaieModel;

class DetailGrilleCategoriePaiePage extends StatefulWidget {
  final GrilleCategoriePaieModel grilleCategoriePaie;
  const DetailGrilleCategoriePaiePage({
    super.key,
    required this.grilleCategoriePaie,
  });

  @override
  State<DetailGrilleCategoriePaiePage> createState() =>
      _DetailGrilleCategoriePaiePageState();
}

class _DetailGrilleCategoriePaiePageState
    extends State<DetailGrilleCategoriePaiePage> {
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
              valeur: widget.grilleCategoriePaie.libelle,
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Les classes",
              isbold: true,
            ),
            Column(
              children: [
                ...widget.grilleCategoriePaie.classes!.map(
                    (classe) => TabledetailBodyMiddle(valeur: classe.libelle))
              ],
            )
          ],
        ),
      ],
    );
  }
}
