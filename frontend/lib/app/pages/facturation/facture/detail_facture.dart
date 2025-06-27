import 'package:flutter/material.dart';
import 'package:frontend/app/pages/facturation/detail_ligne.dart';
import 'package:frontend/app/pages/flux_financier/detail_flux.dart';
import 'package:frontend/helper/facture_proforma_helper.dart';
import 'package:frontend/model/facturation/enum_facture.dart';
import '../../../../style/app_color.dart';
import '../../../../widget/app_accordion.dart';
import '../../../../helper/date_helper.dart';
import '../../../../helper/amout_formatter.dart';
import '../../../../model/facturation/facture_model.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../responsitvity/responsivity.dart';

class MoreDetailFacturePage extends StatelessWidget {
  final FactureModel facture;
  const MoreDetailFacturePage({
    super.key,
    required this.facture,
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
                  valeur: facture.reference,
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
                  valeur: "${Formatter.formatAmount(facture.montant!)} FCFA",
                ),
              ],
            ),
            if (facture.dateEtablissementFacture != null) ...[
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
                            time: facture.dateEtablissementFacture!)
                        : getStringDate(
                            time: facture.dateEtablissementFacture!),
                  ),
                ],
              ),
            ],
            if (facture.client != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Client",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: facture.client!.toStringify(),
                  ),
                ],
              ),
            ],
            if (facture.status != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Statut",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: facture.status!.label,
                  ),
                ],
              ),
            ],
            if (facture.type != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Type",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: facture.type!.label,
                  ),
                ],
              ),
            ],
            if (facture.facturesAcompte.length == 1 &&
                facture.facturesAcompte.first.datePayementEcheante != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Date d'échéance",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: Responsive.isMobile(context)
                        ? (getShortStringDate(
                            time: facture
                                .facturesAcompte.first.datePayementEcheante!,
                          ))
                        : (getStringDate(
                            time: facture
                                .facturesAcompte.first.datePayementEcheante!,
                          )),
                  ),
                ],
              ),
            ],
            if (facture.dateDebutFacturation != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Date de début de facturation",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: Responsive.isMobile(context)
                        ? getShortStringDate(
                            time: facture.dateDebutFacturation!)
                        : getStringDate(time: facture.dateDebutFacturation!),
                  ),
                ],
              ),
            ],
            if (facture.reduction != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Réduction",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: "${Formatter.formatAmount(
                      calculerReduction(
                        lignes: facture.ligneFactures!,
                        reduction: facture.reduction!,
                      ),
                    )} FCFA",
                  ),
                ],
              ),
            ],
            if (facture.tva != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "TVA appliquée",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: facture.tva! ? "Oui" : "Non",
                  ),
                ],
              ),
            ],
            if (facture.isConvertFromProforma != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Obtenu à partir d'un proforma",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: facture.isConvertFromProforma! ? "Oui" : "Non",
                  ),
                ],
              ),
            ],
            if (facture.regenerate != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Régénérable",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: facture.regenerate! ? "Oui" : "Non",
                  ),
                ],
              ),
              
            ],
            if (facture.type == TypeFacture.recurrent)
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Régénerée",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: duration(
                      date: facture.dateDebutFacturation!.add(
                        Duration(
                          milliseconds: facture.generatePeriod!,
                        ),
                      ),
                    ),
                  ),
                ],
              ), 
            if (facture.generatePeriod != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Période de régénération",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: "${convertDuration(
                      durationMs: facture.generatePeriod!,
                    ).compteur} ${convertDuration(
                      durationMs: facture.generatePeriod!,
                    ).unite}",
                  ),
                ],
              ),
            ],
            if (facture.delaisPayment != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Délai de paiement",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: "${convertDuration(
                      durationMs: facture.delaisPayment!,
                    ).compteur} ${convertDuration(
                      durationMs: facture.delaisPayment!,
                    ).unite}",
                  ),
                ],
              ),
            ],
            if (facture.banques != null && facture.banques!.isNotEmpty) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Banques",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: facture.banques!.isNotEmpty
                        ? facture.banques!.map((banque) {
                            int index = facture.banques!.indexOf(banque);
                            bool isLast = index == facture.banques!.length - 1;
                            return banque.name + (isLast ? '' : ', ');
                          }).join('')
                        : "",
                  ),
                ],
              ),
            ],
/*      if (facture.penalty != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Pénalité",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: facture.penalty != null ? "Oui" : "Non",
                  ),
                ],
              ),
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Pénalité réglée",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: facture.penalty!.isPaid ? "Oui" : "Non",
                  ),
                ],
              ),
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Montant de pénalité",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: Formatter.formatAmount(facture.penalty!.montant),
                  ),
                ],
              ),
            ], */
            if (facture.dateEnregistrement != null) ...[
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Créée",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: Responsive.isMobile(context)
                        ? getShortStringDate(time: facture.dateEnregistrement!)
                        : getStringDate(time: facture.dateEnregistrement!),
                  ),
                ],
              ),
            ],
          ],
        ),
        if (facture.commentaires.isNotEmpty) ...[
          AppAccordion(
            header: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Commentaires",
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
                    facture.commentaires.length.toString(),
                  ),
                )
              ],
            ),
            content: Column(
              children: facture.commentaires.asMap().entries.map((entry) {
                int index = entry.key;
                var commentaire = entry.value;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: AppColor.popGrey,
                            child: Text(
                              "Commentaire ${index + 1}",
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
                              valeur: "Message",
                              isbold: true,
                            ),
                            TabledetailBodyMiddle(
                              valeur: commentaire!.message,
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
                              valeur: commentaire.editer!.toStringify(),
                              isbold: true,
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
                              valeur: getStringDate(time: commentaire.date),
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
        ],
     
        
        if (facture.ligneFactures!.isNotEmpty) ...[
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
                    facture.ligneFactures!.length.toString(),
                  ),
                )
              ],
            ),
            content: Column(
              children: facture.ligneFactures!.asMap().entries.map((entry) {
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
        if (facture.facturesAcompte.isNotEmpty) ...[
          AppAccordion(
            header: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Factures d'acompte",
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
                    facture.facturesAcompte.length.toString(),
                  ),
                )
              ],
            ),
            content: Column(
              children: facture.facturesAcompte.map((acompte) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: AppColor.popGrey,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Tranche ${acompte.rang}",
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
                              valeur: "Pourcentage",
                              isbold: true,
                            ),
                            TabledetailBodyMiddle(
                              valeur: '${acompte.pourcentage}%',
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
                                valeur: Formatter.formatAmount(
                                    facture.montant! *
                                        acompte.pourcentage /
                                        100)),
                          ],
                        ),
                      TableRow(
                        decoration: tableDecoration(context),
                        children: [
                          const TabledetailBodyMiddle(
                            valeur: "Réglée",
                            isbold: true,
                          ),
                          TabledetailBodyMiddle(
                            valeur: acompte.isPaid! ? "oui" : "Non",
                          ),
                        ],
                      ),
                      TableRow(
                        decoration: tableDecoration(context),
                        children: [
                          const TabledetailBodyMiddle(
                            valeur: "Pénalité applicable",
                            isbold: true,
                          ),
                          TabledetailBodyMiddle(
                            valeur: acompte.canPenalty ? "Oui" : "Non",
                          ),
                        ],
                      ),

                        
                        TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            const TabledetailBodyMiddle(
                              valeur: "Date d'envoi",
                              isbold: true,
                            ),
                            TabledetailBodyMiddle(
                                valeur: Responsive.isMobile(context)
                                    ? getShortStringDate(
                                        time: acompte.dateEnvoieFacture)
                                    : getStringDate(
                                        time: acompte.dateEnvoieFacture)),
                          ],
                        ),
                        TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            const TabledetailBodyMiddle(
                              valeur: "Date d'échéance",
                              isbold: true,
                            ),
                            TabledetailBodyMiddle(
                              valeur: acompte.datePayementEcheante != null
                                  ? Responsive.isMobile(context)
                                      ? getShortStringDate(
                                          time: acompte.datePayementEcheante!)
                                      : getStringDate(
                                          time: acompte.datePayementEcheante!)
                                  : "Non renseigné",
                            ),
                          ],
                        ),
                        if (acompte.penalty != null) ...[
                          TableRow(
                            decoration: marktableDecoration(context),
                            children: [
                              const TabledetailBodyMiddle(
                              valeur: "Retard",
                                isbold: true,
                              ),
                              TabledetailBodyMiddle(valeur: ""),
                            ],
                          ),
                          TableRow(
                            decoration: tableDecoration(context),
                            children: [
                              TabledetailBodyMiddle(
                                valeur: "Montant",
                                isbold: true,
                              ),
                              TabledetailBodyMiddle(
                                valeur: Formatter.formatAmount(
                                  acompte.penalty!.montant,
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            decoration: tableDecoration(context),
                            children: [
                              TabledetailBodyMiddle(
                              valeur: "Réglée",
                                isbold: true,
                              ),
                              TabledetailBodyMiddle(
                                valeur: acompte.penalty!.isPaid ? "Oui" : "Non",
                              ),
                            ],
                          ),
                          TableRow(
                            decoration: tableDecoration(context),
                            children: [
                              TabledetailBodyMiddle(
                              valeur: "Nombre de jours de retard",
                                isbold: true,
                              ),
                              TabledetailBodyMiddle(
                                valeur:
                                    "${acompte.penalty!.nombreRetard} jours",
                              ),
                            ],
                          ),
                        ],
                    ]),
                    if (acompte.oldPenalties != null &&
                        acompte.oldPenalties!.isNotEmpty) ...[
                      Table(children: [
                        TableRow(
                          children: [
                            AppAccordion(
                              header: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Text(
                                        "Penalités",
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
                                      acompte.oldPenalties!.length.toString(),
                                    ),
                                  )
                                ],
                              ),
                              content: Column(
                                children: acompte.oldPenalties!
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  var oldPenaltie = entry.value;
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              color: AppColor.popGrey,
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                "Pénalité ${index + 1}",
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
                                                valeur: oldPenaltie.libelle,
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
                                                valeur:
                                                    "${Formatter.formatAmount(oldPenaltie.montant)} FCFA",
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            decoration: tableDecoration(context),
                                            children: [
                                              const TabledetailBodyMiddle(
                                                valeur: "Jour de retard",
                                                isbold: true,
                                              ),
                                              TabledetailBodyMiddle(
                                                valeur:
                                                    "${oldPenaltie.nbreRetard}",
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
                          ],
                        ),
                      ])
                    ],          
                  ],
                );
              }).toList(),
            ),
          ),
        ],
        
        
        if (facture.payements != null && facture.payements!.isNotEmpty) ...[
          AppAccordion(
            header: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Encaissements",
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
                    facture.payements!.length.toString(),
                  ),
                )
              ],
            ),
            content: Column(
              children: facture.payements!.asMap().entries.map((entry) {
                int index = entry.key;
                var paiement = entry.value;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: AppColor.popGrey,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Encaissement ${index + 1}",
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
                    DetailFluxPage(flux: paiement)
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
