import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/helper/amout_formatter.dart';
import '../../../../helper/date_helper.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../helper/open_file.dart';
import '../../../model/flux_financier/debt_model.dart';
import '../../responsitvity/responsivity.dart';

class DetailDebtPage extends StatelessWidget {
  final DebtModel debt;
  const DetailDebtPage({
    super.key,
    required this.debt,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
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
              valeur: "Libellé",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: debt.libelle,
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
              valeur: Formatter.formatAmount(debt.montant),
            ),
          ],
        ),
        if (debt.client != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              TabledetailBodyMiddle(
                valeur: "Fournisseur",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: debt.client!.toStringify(),
              ),
            ],
          ),
        ],
        if (debt.referenceFacture != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Référence",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: debt.referenceFacture!,
              ),
            ],
          ),
        ],

        if (debt.user != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Enregistré par",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: debt.user!.personnel!.toStringify(),
              ),
            ],
          ),
        ],
        ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Date d'opération",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: Responsive.isMobile(context)
                    ? getShortStringDate(time: debt.dateOperation)
                    : getStringDate(time: debt.dateOperation),
              ),
            ],
          ),
        ],
        if (debt.pieceJustificative != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Preuve",
                isbold: true,
              ),
              GestureDetector(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ).copyWith(
                        right: 12,
                        left: 8,
                      ),
                      child: TextButton.icon(
                        label: const Text("Ouvrir"),
                        icon: getFileType(debt.pieceJustificative!) == "image"
                            ? const Icon(
                                Icons.image,
                                size: 18,
                              )
                            : const Icon(
                                Icons.picture_as_pdf,
                                size: 18,
                              ),
                        onPressed: () {
                          showPreuve();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        if (debt.dateEnregistrement != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Date d'enregistrement",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: Responsive.isMobile(context)
                    ? getShortStringDate(time: debt.dateEnregistrement!)
                    : getStringDate(time: debt.dateEnregistrement!),
              ),
            ],
          ),
        ],
      ],
    );
  }

  showPreuve() async {
    await openFile(name: debt.pieceJustificative!);
  }
}
