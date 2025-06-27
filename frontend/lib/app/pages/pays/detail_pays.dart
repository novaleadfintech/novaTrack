import 'package:flutter/cupertino.dart';
import 'package:frontend/model/pays_model.dart';
import '../../../helper/string_helper.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';
import '../../responsitvity/responsivity.dart';

class MoreDatailPaysPage extends StatelessWidget {
  final PaysModel pays;
  const MoreDatailPaysPage({
    super.key,
    required this.pays,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        0: Responsive.isMobile(context)
            ? const FlexColumnWidth()
            : const FlexColumnWidth(2)
      },
      children: [
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Nom",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: capitalizeFirstLetter(word: pays.name),
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Indicatif",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: "+${pays.code}",
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Taux TVA",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: "${pays.tauxTVA}%",
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Nombre de chiffres du téléphone",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: pays.phoneNumber.toString(),
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Initiaux des numéros téléphoniques",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: pays.initiauxPays.isNotEmpty
                  ? pays.initiauxPays.join(", ")
                  : "Aucun",
            ),
          ],
        ),
      ],
    );
  }
}
