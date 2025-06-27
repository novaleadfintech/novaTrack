import 'package:flutter/material.dart';
import '../../../../helper/amout_formatter.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/bulletin_paie/decouverte_model.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';

class MoreDetaildecouvertePage extends StatelessWidget {
  final DecouverteModel decouverte;
  const MoreDetaildecouvertePage({
    super.key,
    required this.decouverte,
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
                  valeur: decouverte.salarie.personnel.nom,
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
                  valeur: decouverte.salarie.personnel.prenom,
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
                  valeur: decouverte.salarie.personnel.poste!,
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
                  valeur: Formatter.formatAmount(decouverte.montant),
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Moyen de payement",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: decouverte.moyenPayement.libelle,
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Compte de payement",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: decouverte.banque.name,
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Réference de transaction",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: decouverte.referenceTransaction!,
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Date d'enregistrement",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: getStringDate(time: decouverte.dateEnregistrement),
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Status",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: decouverte.status.label,
                ),
              ],
            ),

            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Durée de reversement",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: "${decouverte.dureeReversement} fois",
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Montant restant à payer",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: Formatter.formatAmount(decouverte.montantRestant),
                ),
              ],
            ),
            TableRow(
              decoration: tableDecoration(context),
              children: [
                const TabledetailBodyMiddle(
                  valeur: "Justification",
                  isbold: true,
                ),
                TabledetailBodyMiddle(
                  valeur: decouverte.justification,
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
