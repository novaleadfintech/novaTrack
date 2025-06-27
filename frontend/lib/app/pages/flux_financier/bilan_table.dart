import 'package:flutter/material.dart';
import '../utils/flux_util.dart';
import '../../responsitvity/responsivity.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';

class BilanTable extends StatefulWidget {
  final List<FluxFinancierModel> paginatedBilanData;

  const BilanTable({
    super.key,
    required this.paginatedBilanData,
  });

  @override
  State<BilanTable> createState() => _BilanTableState();
}

class _BilanTableState extends State<BilanTable> {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      children: [
        SingleChildScrollView(
          child: Table(
            columnWidths: {
              4: const FixedColumnWidth(50),
              2: Responsive.isMobile(context)
                  ? const FixedColumnWidth(30)
                  : const FlexColumnWidth(),
              3: Responsive.isMobile(context)
                  ? const FixedColumnWidth(30)
                  : const FixedColumnWidth(180),
              0: const FlexColumnWidth(2)
            },
            children: [
              Responsive.isMobile(context)
                  ? tableHeader(
                      tablesTitles: bilanTableTitlesSmall,
                      context,
                    )
                  : tableHeader(
                      tablesTitles: bilanTableTitles,
                      context,
                    ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                4: const FixedColumnWidth(50),
                2: Responsive.isMobile(context)
                    ? const FixedColumnWidth(30)
                    : const FlexColumnWidth(),
                3: Responsive.isMobile(context)
                    ? const FixedColumnWidth(30)
                    : const FixedColumnWidth(180),
                0: const FlexColumnWidth(2)
              },
              children: [
                ...widget.paginatedBilanData.map(
                  (fluxFinancier) => isMobile
                      ? TableRow(
                          decoration: fluxFinancier.isInput()
                              ? inputTableDecoration(context)
                              : outputTableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: fluxFinancier.libelle!,
                            ),
                            TableBodyMiddle(
                              valeur: Formatter.formatAmount(
                                fluxFinancier.montant,
                              ),
                            ),
                          ],
                        )
                      : TableRow(
                          decoration: fluxFinancier.isInput()
                              ? inputTableDecoration(context)
                              : outputTableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: fluxFinancier.libelle!,
                            ),
                            TableBodyMiddle(
                              valeur: Formatter.formatAmount(
                                fluxFinancier.montant,
                              ),
                            ),
                            TableBodyMiddle(
                              valeur: fluxFinancier.moyenPayement!.libelle,
                            ),
                            TableBodyMiddle(
                              valeur: getStringDate(
                                time: fluxFinancier.dateOperation!,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
