import 'package:flutter/material.dart';
import 'package:frontend/helper/open_file.dart';
import 'package:frontend/model/flux_financier/type_flux_financier.dart';
import 'package:frontend/widget/affiche_information_on_pop_pop.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../style/app_color.dart';
import '../../../style/app_style.dart';
import '../../../widget/app_accordion.dart';
import '../../../widget/table_body_middle.dart';
import '../../responsitvity/responsivity.dart';

class DetailFluxPage extends StatelessWidget {
  final FluxFinancierModel flux;
  const DetailFluxPage({
    super.key,
    required this.flux,
  });

  showPreuve() async {
    await openFile(name: flux.pieceJustificative!);
  }

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
            
            if (flux.client != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  TabledetailBodyMiddle(
                    valeur: flux.type == FluxFinancierType.input
                        ? "Client"
                        : "Fournisseur",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: flux.client!.toStringify(),
                  ),
                ],
              ),
            ],
            
            if (flux.reference != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Référence",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: flux.reference!,
                  ),
                ],
              ),
            ],
            if (flux.reference != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Numéro de pièce",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: flux.referenceTransaction!,
                  ),
                ],
              ),
            ],
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Libellé",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: flux.libelle!,
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
                  valeur: "${Formatter.formatAmount(flux.montant)} FCFA",
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
                  valeur: flux.type!.label,
                ),
              ],
            ),
            if (flux.moyenPayement != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Canal",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(valeur: flux.moyenPayement!.libelle),
                ],
              ),
            ],
            if (flux.bank != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  TabledetailBodyMiddle(
                    valeur: flux.type == FluxFinancierType.output
                        ? "Destination des fonds"
                        : "Sources des fonds",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: flux.bank!.name,
                        
                  ),
                ],
              ),
            ],
            if (flux.dateOperation != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Date de paiement",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: Responsive.isMobile(context)
                        ? getShortStringDate(time: flux.dateOperation!)
                        : getStringDate(time: flux.dateOperation!),
                  ),
                ],
              ),
            ],
            if (flux.user != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Enregistré par",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur:
                        "${flux.user!.personnel!.nom} ${flux.user!.personnel!.prenom}",
                  ),
                ],
              ),
            ],
            if (flux.dateEnregistrement != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Enregistré",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: Responsive.isMobile(context)
                        ? getShortStringDate(
                            time: flux.dateEnregistrement!)
                        : getStringDate(time: flux.dateEnregistrement!),
                  ),
                ],
              ),
            ],
            if (flux.pieceJustificative != null) ...[
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
                            icon:
                                getFileType(flux.pieceJustificative!) ==
                                        "image"
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
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Statut",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: flux.status!.label,
                ),
              ],
            ),
          ],
        ),
        if (flux.validated != null && flux.validated!.isNotEmpty) ...[
          AppAccordion(
            header: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Validations",
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
                    flux.validated!.length.toString(),
                  ),
                )
              ],
            ),
            content: Column(
              children: flux.validated!.asMap().entries.map((entry) {
                int index = entry.key;
                var validate = entry.value;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.popGrey,
                    ),
                  ),
                  child: Column(children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: AppColor.popGrey,
                            child: Text(
                              "Validation ${index + 1}",
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
                    Table(
                      children: [
                        TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TabledetailBodyMiddle(
                              valeur: "Etat de validation",
                              isbold: true,
                            ),
                            TabledetailBodyMiddle(
                              valeur: validate.validateStatus.label,
                            ),
                          ],
                        ),
                        TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TabledetailBodyMiddle(
                              valeur: "Par",
                              isbold: true,
                            ),
                            TabledetailBodyMiddle(
                              valeur: validate.validater.toStringify(),
                            ),
                          ],
                        ),
                        TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TabledetailBodyMiddle(
                              valeur: "Date",
                              isbold: true,
                            ),
                            TabledetailBodyMiddle(
                              valeur: getStringDate(time: validate.date),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Table(
                      children: [
                        TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TabledetailBodyMiddle(
                              valeur: "Commentaire",
                              isbold: true,
                            ),
                            TabledetailBodyMiddle(
                              valeur: validate.commentaire,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (flux.isFromSystem!)
                      ShowNotificationInformation(
                        message: "Ecrit par le système",
                      )
                  ]),
                );
              }).toList(),
            ),
          ),
        ],
      
      
      ],
    );
  }
}
