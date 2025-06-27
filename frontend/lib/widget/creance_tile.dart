import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/model/client/client_model.dart';
import 'package:frontend/style/app_color.dart';
import '../app/pages/creance/add_comment.dart';
import '../app/pages/utils/creance_util.dart';
import '../app/responsitvity/responsivity.dart';
import '../helper/date_helper.dart';
import '../model/facturation/facture_model.dart';
import '../model/flux_financier/creance_model.dart';
import '../style/app_style.dart';
import 'app_accordion.dart';
import 'table_body_middle.dart';
import 'table_header.dart';

import '../helper/amout_formatter.dart';

class CreanceTile extends StatelessWidget {
  final CreanceModel creance;
  final VoidCallback refresh;

  const CreanceTile({
    super.key,
    required this.creance,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    //final isTablet = Responsive.isTablet(context);
    return AppAccordion(
      header: isMobile
          ? Table(
              columnWidths: {
                2: isMobile
                    ? const FixedColumnWidth(70)
                    : const FixedColumnWidth(78),
                1: isMobile
                    ? const FixedColumnWidth(128)
                    : const FixedColumnWidth(158),
              },
              children: [
                TableRow(
                  children: [
                    TableBodyMiddle(
                      valeur: creance.client!.toStringify(),
                    ),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(creance.montantRestant),
                    ),
                    TableBodyMiddle(
                        valeur: creance.factures!.first.facturesAcompte
                                    .firstWhere(
                                      (fac) => fac.isPaid == false,
                                    )
                                    .datePayementEcheante !=
                                null
                            ? duration(
                                date: creance.factures!.first.facturesAcompte
                                    .firstWhere(
                                      (fac) =>
                                          fac.datePayementEcheante != null &&
                                          fac.isPaid == false,
                                    )
                                    .datePayementEcheante!,
                              )
                            : "..."),
                  ],
                ),
              ],
            )
          : Table(
              columnWidths: const {3: FixedColumnWidth(108)},
              children: [
                TableRow(
                  children: [
                    TableBodyMiddle(
                      valeur: creance.client!.toStringify(),
                    ),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(creance.montantRestant),
                    ),
                    TableBodyMiddle(
                      valeur: creance.factures!.first.facturesAcompte
                                  .firstWhere(
                                    (fac) => fac.isPaid == false,
                                  )
                                  .datePayementEcheante !=
                              null
                          ? getStringDate(
                              time: creance.factures!.first.facturesAcompte
                                  .firstWhere(
                                    (fac) =>
                                        fac.datePayementEcheante != null &&
                                        fac.isPaid == false,
                                  )
                                  .datePayementEcheante!,
                            )
                          : "Non renseigné",
                    ),
                    TableBodyMiddle(
                        valeur: creance.factures!.first.facturesAcompte
                                    .firstWhere(
                                      (fac) => fac.isPaid == false,
                                    )
                                    .datePayementEcheante !=
                                null
                            ? duration(
                                date: creance.factures!.first.facturesAcompte
                                    .firstWhere(
                                      (fac) =>
                                          fac.datePayementEcheante != null &&
                                          fac.isPaid == false,
                                    )
                                    .datePayementEcheante!,
                              )
                            : "..."),
                  ],
                )
              ],
            ),
      content: CreanceDetail(
        refresh: refresh,
        factures: creance.factures!,
        client: creance.client!,
      ),
    );
  }
}

class CreanceDetail extends StatefulWidget {
  final List<FactureModel> factures;
  final ClientModel client;
  final VoidCallback refresh;


  const CreanceDetail({
    super.key,
    required this.refresh,
    required this.factures,
    required this.client,
  });

  @override
  State<CreanceDetail> createState() => _CreanceDetailState();
}

class _CreanceDetailState extends State<CreanceDetail> {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Table(
      columnWidths: {
        2: isMobile ? const IntrinsicColumnWidth() : const FlexColumnWidth(),
        1: isMobile ? const IntrinsicColumnWidth() : const FlexColumnWidth(),
        3: const IntrinsicColumnWidth(),
        4: const FixedColumnWidth(50)
      },
      children: [
        tableHeader(
          context,
          tablesTitles: isMobile
              ? creanceFactureTableTitlesSmall
              : creanceFactureTableTitles,
        ),
        ...widget.factures.expand((facture) {
          final facturesAcompteImpaye = facture.facturesAcompte.where(
            (factureAcompte) => factureAcompte.isPaid == false,
          );

          return facturesAcompteImpaye.map(
            (factureAcompte) {
              final montant =
                  facture.montant! * (factureAcompte.pourcentage) / 100;
              final reference = facture.facturesAcompte.length == 1
                  ? facture.reference
                  : '${facture.reference} - ${factureAcompte.rang}';
              final datePayement = factureAcompte.datePayementEcheante != null
                  ? getStringDate(time: factureAcompte.datePayementEcheante!)
                  : "Non renseignée";

              return isMobile
                  ? TableRow(
                      decoration: tableDecoration(context),
                      children: [
                        TableBodyMiddle(valeur: facture.reference),
                        TableBodyMiddle(
                          valeur: Formatter.formatAmount(montant),
                        ),
                        TableBodyMiddle(
                          valeur: factureAcompte.datePayementEcheante != null
                              ? shortDuration(
                                  date: factureAcompte.datePayementEcheante!)
                              : "...",
                        ),
                        IconButton(
                          onPressed: () {
                            addComment(
                              facture: facture,
                            );
                          },
                          icon: Icon(
                            Icons.comment,
                              color: facture.commentaires.isEmpty
                                  ? AppColor.grayColor
                                  : AppColor.redColor
                                
                          ),
                        )
                      ],
                    )
                  : TableRow(
                      decoration: tableDecoration(context),
                      children: [
                        TableBodyMiddle(
                          valeur: reference,
                        ),
                        TableBodyMiddle(
                          valeur: Formatter.formatAmount(montant),
                        ),
                        TableBodyMiddle(
                          valeur: datePayement,
                        ),
                        TableBodyMiddle(
                          valeur: factureAcompte.datePayementEcheante != null
                              ? duration(
                                  date: factureAcompte.datePayementEcheante!)
                              : "...",
                        ),
                        IconButton(
                          onPressed: () {
                            addComment(facture: facture);
                          },
                          icon: Icon(
                            Icons.comment,
                              color: facture.commentaires.isEmpty
                                  ? AppColor.grayColor
                                  : AppColor.redColor
                          ),
                        ),
                      ],
                    );
            },
          );
        }),
      ],
    );
  }

  void addComment({required FactureModel facture}) {
    showResponsiveDialog(
      context,
      content: AddCommentPage(
        facture: facture,
        refresh: widget.refresh,
      ),
      title:
          "Qu'à dit ${widget.client.toStringify()} à propos du payement de la facture N° ${facture.reference} ?",
    );
  }
}
