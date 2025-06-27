import 'package:flutter/material.dart';
import '../detail_ligne.dart';
import '../../../../model/facturation/proforma_model.dart';
import '../../../../helper/amout_formatter.dart';
import '../../../../helper/date_helper.dart';
import '../../../../style/app_color.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/app_accordion.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../responsitvity/responsivity.dart';

class MoreDetailProformaPage extends StatelessWidget {
  final ProformaModel proforma;
  const MoreDetailProformaPage({
    super.key,
    required this.proforma,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
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
                  valeur: "Référence",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: proforma.reference,
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Montant",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: "${Formatter.formatAmount(proforma.montant!)} FCFA",
                ),
              ],
            ),
            if (proforma.dateEtablissementProforma != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Date d'établissement",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: Responsive.isMobile(context)
                        ? getShortStringDate(
                            time: proforma.dateEtablissementProforma!)
                        : getStringDate(
                            time: proforma.dateEtablissementProforma!),
                  ),
                ],
              ),
            ],
            if (proforma.client != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Client",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: proforma.client!.toStringify(),
                  ),
                ],
              ),
            ],
            if (proforma.status != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Statut",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: proforma.status!.label,
                  ),
                ],
              ),
            ],
            if (proforma.dateEnvoie != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Date d'envoi",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: Responsive.isMobile(context)
                        ? getShortStringDate(time: proforma.dateEnvoie!)
                        : getStringDate(time: proforma.dateEnvoie!),
                  ),
                ],
              ),
            ],
            if (proforma.garantyTime != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Garantie avant service",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: proforma.garantyTime == 0
                        ? "Pas de garantie"
                        : "${convertDuration(
                            durationMs: proforma.garantyTime!,
                          ).compteur} ${convertDuration(
                            durationMs: proforma.garantyTime!,
                          ).unite}",
                  ),
                ],
              ),
            ],
            if (proforma.dateEnregistrement != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Créée",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: Responsive.isMobile(context)
                        ? getShortStringDate(time: proforma.dateEnregistrement!)
                        : getStringDate(time: proforma.dateEnregistrement!),
                  ),
                ],
              ),
            ],
          ],
        ),
        if (proforma.ligneProformas!.isNotEmpty) ...[
          AppAccordion(
            header: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Services",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 12,
                  child: Text(
                    proforma.ligneProformas!.length.toString(),
                  ),
                )
              ],
            ),
            content: Column(
              children: proforma.ligneProformas!.asMap().entries.map((entry) {
                int index = entry.key;
                var ligne = entry.value;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: AppColor.popGrey,
                            child: Text(
                              "Services ${index + 1}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    MoreDetailLignePage(ligne: ligne)
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
