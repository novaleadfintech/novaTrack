import 'package:flutter/material.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';

class DetailMoyenPaiementPage extends StatefulWidget {
  final MoyenPaiementModel moyenPaiement;
  const DetailMoyenPaiementPage({
    super.key,
    required this.moyenPaiement,
  });

  @override
  State<DetailMoyenPaiementPage> createState() => _DetailMoyenPaiementPageState();
}

class _DetailMoyenPaiementPageState extends State<DetailMoyenPaiementPage> {
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
              valeur: widget.moyenPaiement.libelle,
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Type",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.moyenPaiement.type == null
                  ? "inconnu"
                  : widget.moyenPaiement.type!.label,
            ),
          ],
        ),
      ],
    );
  }
}
