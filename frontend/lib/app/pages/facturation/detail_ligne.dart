import 'package:flutter/material.dart';
import 'package:frontend/model/facturation/ligne_model.dart';
import 'package:frontend/model/service/enum_service.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../model/service/service_prix_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/app_accordion.dart';
import '../../../widget/table_body_middle.dart';
import '../../responsitvity/responsivity.dart';

class MoreDetailLignePage extends StatelessWidget {
  final LigneModel ligne;
  const MoreDetailLignePage({
    super.key,
    required this.ligne,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        Table(
          columnWidths: {
            0: Responsive.isMobile(context)
                ? const FlexColumnWidth()
                : const FlexColumnWidth(),
          },
          children: [
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Désignation",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: ligne.designation,
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Prix",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur:
                      "${Formatter.formatAmount(ligne.service!.nature == NatureService.unique ? ligne.service!.prix! : ligne.service!.tarif.firstWhere(
                          (tarif) {
                            if (tarif!.maxQuantity == null) {
                              return ligne.quantite! >= tarif.minQuantity;
                            } else {
                              return ligne.quantite! >= tarif.minQuantity &&
                                  ligne.quantite! <= tarif.maxQuantity!;
                            }
                          },
                          orElse: () => ServiceTarifModel(
                            minQuantity: 1,
                            prix: 0,
                          ),
                        )!.prix)} FCFA",
                ),
              ],
            ),
            if (ligne.prixSupplementaire != null &&
                ligne.prixSupplementaire! > 0)
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Prix supplémantaire",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur:
                        "${Formatter.formatAmount(ligne.prixSupplementaire!)} FCFA",
                  ),
                ],
              ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Quantité",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: ligne.quantite.toString(),
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
                  valeur: "${Formatter.formatAmount(ligne.montant)} FCFA",
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Unité",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: ligne.unit!,
                ),
              ],
            ),
            // TableRow(
            //   decoration: tableDecoration(context),
            //   children: [
            //     const TabledetailBodyMiddle(
            //       valeur: "Remise",
            //       isbold: true,
            //     ),
            //     TabledetailBodyMiddle(
            //       valeur: "${Formatter.formatAmount(ligne.remise!)} FCFA",
            //     ),
            //   ],
            // ),
            if (ligne.dureeLivraison != null)
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Durée de livraison",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: "${convertDuration(
                      durationMs: ligne.dureeLivraison!,
                    ).compteur} ${convertDuration(
                      durationMs: ligne.dureeLivraison!,
                    ).unite}",
                  ),
                ],
              ),
          ],
        ),
        if (ligne.fraisDivers!.isNotEmpty) ...[
          AppAccordion(
            header: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Frais divers",
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
                    ligne.fraisDivers!.length.toString(),
                  ),
                )
              ],
            ),
            content: Column(
              children: ligne.fraisDivers!.map((frais) {
                return Column(
                  children: [
                    Table(
                      children: [
                        TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TabledetailBodyMiddle(
                              valeur: frais.libelle,
                            ),
                            TabledetailBodyMiddle(
                              valeur: frais.montant.toString(),
                              isbold: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ]
      ],
    ));
  }
}
