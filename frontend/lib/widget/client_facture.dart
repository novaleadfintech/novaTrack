/* import 'package:flutter/material.dart';
import 'package:frontend/app/pages/utils/client_util.dart';
import 'package:frontend/app/responsitvity/responsivity.dart';
import 'package:frontend/style/app_style.dart';
import 'package:frontend/widget/table_body_middle.dart';
import 'package:frontend/widget/table_header.dart';
import 'package:gap/gap.dart';

class ClientFacture extends StatelessWidget {
  const ClientFacture({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDADCE0),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Facture",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Gap(4),
          SingleChildScrollView(
            child: Table(
              columnWidths: {
                1: isMobile
                    ? const IntrinsicColumnWidth()
                    : const FlexColumnWidth(),
                2: isMobile
                    ? const IntrinsicColumnWidth()
                    : const FlexColumnWidth(),
              },
              children: [
                tableHeader(
                  context,
                  tablesTitles: isMobile
                      ? clientFactureTableColumnsmall
                      : clientFactureTableColumn,
                ),
                ...[
                /*   facture,
                  facture,
                  facture, */
                ].map(
                  (e) {
                    final montantTotal = facture.montant;
                    return isMobile
                        ? TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  width: 2,
                                ),
                                bottom: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  width: 2,
                                ),
                              ),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            children: [
                              TableBodyMiddle(
                                valeur: e.reference,
                              ),
                              TableBodyMiddle(
                                valeur: montantTotal.toString(),
                              ),
                              TableBodyMiddle(
                                valeur: e.status! .label,
                              ),
                            ],
                          )
                        : TableRow(
                            decoration: tableDecoration,
                            children: [
                              TableBodyMiddle(
                                valeur: e.reference,
                              ),
                              TableBodyMiddle(
                                valeur: e.type!.label,
                              ),
                              TableBodyMiddle(
                                valeur: e.etat!.label,
                              ),
                              TableBodyMiddle(
                                valeur: montantTotal.toString(),
                              ),
                              TableBodyMiddle(
                                valeur: e.status!.label,
                              ),
                            ],
                          );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 */