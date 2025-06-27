import 'package:flutter/material.dart';
import 'package:frontend/app/pages/detail_pop.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../responsitvity/responsivity.dart';
import '../utils/flux_util.dart';
import 'validate_detail_page.dart';

class ValidationTable extends StatefulWidget {
  final List<FluxFinancierModel> fluxFinanciers;
  final Future<void> Function() refresh;
  const ValidationTable({
    super.key,
    required this.fluxFinanciers,
    required this.refresh,
  });

  @override
  State<ValidationTable> createState() => _ValidationTableState();
}

class _ValidationTableState extends State<ValidationTable> {
  FluxFinancierModel? selectedFlux; 

  void selectFlux(
    FluxFinancierModel flux,
  ) {
    showDetailDialog(
        context,
        content: ValidateDetailPage(
          flux: flux,
          refresh: widget.refresh,
        ),
        title: "Vérification et validation",
      );
    }

  

@override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          columnWidths: {
            4: const FixedColumnWidth(60),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(60)
                : const FlexColumnWidth(),
            3: const FixedColumnWidth(180),
            0: const FlexColumnWidth(2)
          },
          children: [
            Responsive.isMobile(context)
                ? tableHeader(
                    tablesTitles: fluxTableTitlesSmall,
                    context,
                  )
                : tableHeader(
                    tablesTitles: fluxTableTitles,
                    context,
                  ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                4: const FixedColumnWidth(60),
                2: Responsive.isMobile(context)
                    ? const FixedColumnWidth(60)
                    : const FlexColumnWidth(),
                3: const FixedColumnWidth(180),
                0: const FlexColumnWidth(2)
              },
              children: [
                ...widget.fluxFinanciers.map(
                  (fluxFinancier) => Responsive.isMobile(context)
                      ? TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: fluxFinancier.libelle!,
                            ),
                            TableBodyMiddle(
                              valeur:
                                  Formatter.formatAmount(fluxFinancier.montant),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: TextButton.icon(
                                onPressed: () {
                                  selectFlux(fluxFinancier);
                                },
                                label: Text(
                                  "",
                                ),
                                icon: Icon(Icons.visibility),
                              ),
                            )
                          ],
                        )
                      : TableRow(
                          decoration: tableDecoration(
                            context,
                          ),
                          children: [
                            TableBodyMiddle(
                              valeur: fluxFinancier.libelle!,
                            ),
                            TableBodyMiddle(
                              valeur:
                                  Formatter.formatAmount(fluxFinancier.montant),
                            ),
                            TableBodyMiddle(
                              valeur: fluxFinancier.moyenPayement!.libelle,
                            ),
                            TableBodyMiddle(
                              valeur: getStringDate(
                                time: fluxFinancier.dateOperation!,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: TextButton.icon(
                                onPressed: () {
                                  selectFlux(fluxFinancier);
                                },
                                label: Text(
                                  "",
                                ),
                                icon: Icon(Icons.visibility),
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

