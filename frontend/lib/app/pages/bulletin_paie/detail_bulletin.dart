import 'package:flutter/material.dart';

import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../helper/get_bulletin_period.dart';
import '../../../helper/sign_switch_operation.dart';
import '../../../model/bulletin_paie/bulletin_model.dart';
import '../../../model/bulletin_paie/tranche_model.dart';
import '../../../style/app_color.dart';
import '../../../style/app_style.dart';
import '../../../widget/app_accordion.dart';
import '../../../widget/table_body_middle.dart';

class DetailBulletinPage extends StatelessWidget {
  final BulletinPaieModel bulletin;
  const DetailBulletinPage({
    super.key,
    required this.bulletin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          children: [
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Nom",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: bulletin.salarie.personnel.nom,
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Prénoms",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: bulletin.salarie.personnel.prenom,
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Poste",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: bulletin.salarie.personnel.poste != null
                      ? bulletin.salarie.personnel.poste!.libelle
                      : "Aucun poste",
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Période de peie",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                    valeur:
                      "du ${getStringDate(time: bulletin.debutPeriodePaie)} au ${getStringDate(time: bulletin.finPeriodePaie)}",
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Etat",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: bulletin.etat.label,
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Date d'edition",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: getStringDate(time: bulletin.dateEdition),
                ),
              ],
            ),
            if (bulletin.moyenPayement != null)
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Mode de payement",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: bulletin.moyenPayement!.libelle,
                  ),
                ],
              ),
            if (bulletin.referencePaie != null)
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Référence de paie",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: bulletin.referencePaie!,
                  ),
                ],
              ),
            if (bulletin.datePayement != null)
              TableRow(
                decoration: tableDecoration(context),
                children: [
                  const TabledetailBodyMiddle(
                    valeur: "Date de paiement",
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: getStringDate(time: bulletin.datePayement!),
                  ),
                ],
              ),
          ],
        ),
       
        ...bulletin.rubriques.map((rubrique) {
          return AppAccordion(
            header: Table(
              columnWidths: {0: FlexColumnWidth(2)},
              children: [
                TableRow(children: [
                  TabledetailBodyMiddle(
                    valeur: rubrique.rubrique.rubrique,
                    isbold: true,
                  ),
                  TabledetailBodyMiddle(
                    valeur: rubrique.rubrique.rubriqueIdentity ==
                            RubriqueIdentity.anciennete
                        
                        ? formatAnciennete(rubrique.value)
    
                        : rubrique.value.toString(),
                  )
                ])
              ],
            ),
            content: Column(
              children: [
                Table(
                  columnWidths: {1: FlexColumnWidth(2)},
                  children: [
                    if (rubrique.rubrique.taux != null)
                      TableRow(
                        decoration: tableDecoration(context),
                        children: [
                          const TabledetailBodyMiddle(
                            valeur: "Formule",
                            isbold: true,
                          ),
                          TabledetailBodyMiddle(
                            valeur:
                                "${rubrique.rubrique.taux!.taux}% de ${rubrique.rubrique.taux!.base.rubrique.toLowerCase()}",
                          ),
                        ],
                      ),
                    if (rubrique.rubrique.calcul != null)
                      TableRow(
                        decoration: tableDecoration(context),
                        children: [
                          const TabledetailBodyMiddle(
                            valeur: "Formule",
                            isbold: true,
                          ),
                          TabledetailBodyMiddle(
                              valeur: rubrique.rubrique.calcul!.elements
                                  .map((element) {
                            if (element.type == BaseType.rubrique) {
                              return element.rubrique?.rubrique ?? '';
                            } else if (element.type == BaseType.valeur) {
                              return element.valeur?.toString() ?? '';
                            }
                          }).join(' ${getOperateurSymbol(rubrique.rubrique.calcul!.operateur)} ')),
                        ],
                      ),
                    if (rubrique.rubrique.sommeRubrique != null)
                      TableRow(
                        decoration: tableDecoration(context),
                        children: [
                          const TabledetailBodyMiddle(
                            valeur: "Formule",
                            isbold: true,
                          ),
                          TabledetailBodyMiddle(
                              valeur: rubrique.rubrique.sommeRubrique!.elements
                                  .map((element) {
                            return element.rubrique?.rubrique ?? '';
                          }).join(' ${getOperateurSymbol(rubrique.rubrique.sommeRubrique!.operateur)} ')),
                        ],
                      ),
                    if (rubrique.rubrique.bareme != null &&
                        rubrique.rubrique.bareme!.tranches.isNotEmpty) ...[
                      TableRow(
                        decoration: tableDecoration(context),
                        children: [
                          const TabledetailBodyMiddle(
                            valeur: "Barême",
                            isbold: true,
                          ),
                          const TabledetailBodyMiddle(
                            valeur: "",
                          ),
                        ],
                      ),
                      ...rubrique.rubrique.bareme!.tranches.map(
                        (tranche) => TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TabledetailBodyMiddle(
                              valeur: tranche.max == null
                                  ? "A partir de ${tranche.min}"
                                  : "${tranche.min} à ${tranche.max}",
                              isbold: true,
                            ),
                            if (tranche.value.valeur != null)
                              TabledetailBodyMiddle(
                                valeur: Formatter.formatAmount(
                                    tranche.value.valeur!),
                              ),
                            if (tranche.value.taux != null)
                              TabledetailBodyMiddle(
                                valeur:
                                    "${tranche.value.taux!.taux}% de ${tranche.value.taux!.base.rubrique.toLowerCase()}",
                              ),
                          ],
                        ),
                      ),
                    ],
                    TableRow(
                      decoration: tableDecoration(context),
                      children: [
                        const TabledetailBodyMiddle(
                          valeur: "Valeur",
                          isbold: true,
                        ),
                        TabledetailBodyMiddle(
                          valeur: rubrique.rubrique.rubriqueIdentity ==
                                  RubriqueIdentity.anciennete
                              ? formatAnciennete(rubrique.value)
                              : rubrique.value.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        })
      ,
        if (bulletin.validated != null && bulletin.validated!.isNotEmpty) ...[
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
                    bulletin.validated!.length.toString(),
                  ),
                )
              ],
            ),
            content: Column(
              children: bulletin.validated!.asMap().entries.map((entry) {
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
