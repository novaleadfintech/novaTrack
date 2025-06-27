import 'package:flutter/material.dart';
import 'package:frontend/model/client/categorie_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';

class DetailCategoriePage extends StatefulWidget {
  final CategorieModel categorie;
  const DetailCategoriePage({
    super.key,
    required this.categorie,
  });

  @override
  State<DetailCategoriePage> createState() => _DetailCategoriePageState();
}

class _DetailCategoriePageState extends State<DetailCategoriePage> {
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
              valeur: widget.categorie.libelle,
            ),
          ],
        ),
       
      ],
    );
  }
}
