import 'package:flutter/cupertino.dart';
import 'package:frontend/model/service/enum_service.dart';

import '../../../helper/amout_formatter.dart';
import '../../../helper/string_helper.dart';
import '../../../model/service/service_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';
import '../../responsitvity/responsivity.dart';


class MoreDatailServicePage extends StatelessWidget {
  final ServiceModel service;
  const MoreDatailServicePage({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        0: Responsive.isMobile(context)
            ? const FlexColumnWidth()
            : const FlexColumnWidth()
      },
      children: [
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Libellé",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: capitalizeFirstLetter(word: service.libelle),
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Pays",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: service.country.name,
            ),
          ],
        ),
        if (service.nature == NatureService.unique)
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Prix",
              isbold: true,
            ),
            TabledetailBodyMiddle(
                valeur: "${Formatter.formatAmount(service.prix!)} FCFA",
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
              valeur: service.type!.label,
            ),
          ],
        ),
        
        if (service.description != null && service.description!.isNotEmpty) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Description",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: capitalizeFirstLetter(word: service.description!),
              ),
            ],
          ),
        ],
        if (service.nature == NatureService.multiple &&
            service.tarif.isNotEmpty)
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Tarifs",
                isbold: true,
              ),
              const TabledetailBodyMiddle(
                valeur: "",
              ),
            ],
          ),
        ...service.tarif.map(
          (tarif) => TableRow(
            decoration: tableDecoration(context),
            children: [
              TabledetailBodyMiddle(
                valeur: tarif!.maxQuantity == null
                    ? "A partir de ${tarif.minQuantity}"
                    : "${tarif.minQuantity} - ${tarif.maxQuantity}",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: "${Formatter.formatAmount(tarif.prix)} FCFA",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
