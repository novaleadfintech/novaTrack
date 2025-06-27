import 'package:flutter/material.dart';
import 'package:frontend/helper/sign_switch_operation.dart';
import 'package:frontend/model/bulletin_paie/rubrique.dart';
import '../../../../helper/amout_formatter.dart';
import '../../../../model/bulletin_paie/tranche_model.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';

class DetailRubriquePage extends StatefulWidget {
  final RubriqueBulletin rubrique;
  const DetailRubriquePage({
    super.key,
    required this.rubrique,
  });

  @override
  State<DetailRubriquePage> createState() => _DetailRubriquePageState();
}

class _DetailRubriquePageState extends State<DetailRubriquePage> {
  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "code",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.rubrique.code,
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Libellé",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.rubrique.rubrique,
            ),
          ],
        ),
        if (widget.rubrique.section != null) ...[
          TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Section",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.rubrique.section!.section,
            ),
          ],
          ),
        ],
        if (widget.rubrique.type != null) ...[
          TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "type",
              isbold: true,
            ),
            TabledetailBodyMiddle(
                valeur: widget.rubrique.type!.label,
            ),
          ],
          ),
        ],
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Nature",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.rubrique.nature.label,
            ),
          ],
        ),
        if (widget.rubrique.portee != null)
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Portée",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: widget.rubrique.portee!.label,
              ),
            ],
          ),
        if (widget.rubrique.rubriqueIdentity != null)
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Identité de rubrique",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: widget.rubrique.rubriqueIdentity!.label,
              ),
            ],
          ),
        if (widget.rubrique.taux != null)
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Formule",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur:
                    "${widget.rubrique.taux!.taux}% de ${widget.rubrique.taux!.base.rubrique.toLowerCase()}",
              ),
            ],
          ),
        if (widget.rubrique.calcul != null)
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Formule",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                  valeur: widget.rubrique.calcul!.elements.map((element) {
                if (element.type == BaseType.rubrique) {
                  return element.rubrique?.rubrique ?? '';
                } else if (element.type == BaseType.valeur) {
                  return element.valeur?.toString() ?? '';
                }
              }).join(' ${getOperateurSymbol(widget.rubrique.calcul!.operateur)} ')),
            ],
          ),
        if (widget.rubrique.sommeRubrique != null)
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Formule",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                  valeur:
                      widget.rubrique.sommeRubrique!.elements.map((element) {
                return element.rubrique?.rubrique ?? '';
              }).join(' ${getOperateurSymbol(widget.rubrique.sommeRubrique!.operateur)} ')),
            ],
          ),
        if (widget.rubrique.bareme != null &&
            widget.rubrique.bareme!.tranches.isNotEmpty) ...[
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
          ...widget.rubrique.bareme!.tranches.map(
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
                    valeur: Formatter.formatAmount(tranche.value.valeur!),
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
      ],
    );
  }
}
