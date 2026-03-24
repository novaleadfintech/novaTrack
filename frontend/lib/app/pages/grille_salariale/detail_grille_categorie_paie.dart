 import 'package:flutter/material.dart';
 import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../model/grille_salariale/categorie_paie.dart'
    show GrillepaieCategorieModel;

class DetailGrillepaieCategoriePage extends StatefulWidget {
  final GrillepaieCategorieModel grillepaieCategorie;
  const DetailGrillepaieCategoriePage({
    super.key,
    required this.grillepaieCategorie,
  });

  @override
  State<DetailGrillepaieCategoriePage> createState() =>
      _DetailGrillepaieCategoriePageState();
}

class _DetailGrillepaieCategoriePageState
    extends State<DetailGrillepaieCategoriePage> {
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
              valeur: widget.grillepaieCategorie.libelle,
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
                ...widget.grillepaieCategorie.classes!.map(
                    (classe) => TabledetailBodyMiddle(valeur: classe.libelle))
              ],
            )
          ],
        ),
      ],
    );
  }
}
