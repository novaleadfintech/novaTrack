import 'package:flutter/cupertino.dart';
import 'package:frontend/model/personnel/personnel_model.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/bulletin_paie/salarie_model.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../responsitvity/responsivity.dart';

class DetailSalariePage extends StatelessWidget {
  final SalarieModel salarie;
  const DetailSalariePage({
    super.key,
    required this.salarie,
  });

  @override
  Widget build(BuildContext context) {
    PersonnelModel personnel = salarie.personnel;
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
              valeur: "Nom",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: personnel.nom,
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Prénom",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: personnel.prenom,
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Catégorie de paie",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: salarie.categoriePaie.categoriePaie,
            ),
          ],
        ),
        
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Période de paie",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: (salarie.periodPaie == null)
                  ? "Aucune"
                  : "${convertDuration(
                      durationMs: salarie.periodPaie!,
              ).compteur} ${convertDuration(
                      durationMs: salarie.periodPaie!,
              ).unite}",
            ),
          ],
        ),
        
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Modalité de paiement",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: (salarie.paieManner == null)
                  ? "Aucune"
                  : salarie.paieManner!.label,
            ),
          ],
        ),
        
        if (personnel.email != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Email",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.email!,
              ),
            ],
          ),
        ],
        if (personnel.telephone != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Téléphone",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: "+${personnel.pays!.code} ${personnel.telephone}",
              ),
            ],
          ),
        ],
        if (personnel.pays != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Pays",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.pays!.name,
              ),
            ],
          ),
        ],
        if (personnel.adresse != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Adresse",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.adresse!,
              ),
            ],
          ),
        ],
        if (personnel.sexe != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Sexe",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.sexe!.label,
              ),
            ],
          ),
        ],
        if (personnel.poste != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Poste",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.poste != null
                    ? personnel.poste!.libelle
                    : "Aucun",
              ),
            ],
          ),
        ],
        if (personnel.situationMatrimoniale != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Situation matrimoniale",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.situationMatrimoniale!.label,
              ),
            ],
          ),
        ],
        if (personnel.dateNaissance != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Date de naissance",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: Responsive.isMobile(context)
                    ? getShortStringDate(time: personnel.dateNaissance!)
                    : getStringDate(time: personnel.dateNaissance!),
              ),
            ],
          ),
        ],
        if (personnel.personnePrevenir != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Personne à prévenir",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur:
                    "Nom : ${personnel.personnePrevenir!.nom}\nLien : ${personnel.personnePrevenir!.lien}\nContact : +${personnel.pays!.code} ${personnel.personnePrevenir!.telephone1} ${personnel.personnePrevenir!.telephone2 != null ? "/ +${personnel.pays!.code} ${personnel.personnePrevenir!.telephone2}" : ""}",
              ),
            ],
          ),
        ],
        if (personnel.nombreEnfant != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Nombre d'enfants",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.nombreEnfant.toString(),
              ),
            ],
          ),
        ],
        if (personnel.nombrePersonneCharge != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Nombre de personnes à charge",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.nombrePersonneCharge.toString(),
              ),
            ],
          ),
        ],
        if (personnel.etat != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "État",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.etat!.label,
              ),
            ],
          ),
        ],
        if (personnel.typePersonnel != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Type de personnel",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.typePersonnel!.label,
              ),
            ],
          ),
        ],
        if (personnel.typeContrat != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Type de contrat",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.typeContrat!.label,
              ),
            ],
          ),
        ],
        if (personnel.dateDebut != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Date de début de contrat",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: Responsive.isMobile(context)
                    ? getShortStringDate(time: personnel.dateDebut!)
                    : getStringDate(time: personnel.dateDebut!),
              ),
            ],
          ),
        ],
        if (personnel.dateFin != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Date de fin de contrat",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: Responsive.isMobile(context)
                    ? getShortStringDate(time: personnel.dateFin!)
                    : getStringDate(time: personnel.dateFin!),
              ),
            ],
          ),
        ],
        if (personnel.dureeEssai != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Période d'essai",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: "${(personnel.dureeEssai!).toString()} mois",
              ),
            ],
          ),
        ],
        if (personnel.commentaire != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Commentaire",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: personnel.commentaire!,
              ),
            ],
          ),
        ],
        if (personnel.dateEnregistrement != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Date d'enregistrement",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: Responsive.isMobile(context)
                    ? getShortStringDate(time: personnel.dateEnregistrement!)
                    : getStringDate(time: personnel.dateEnregistrement!),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
