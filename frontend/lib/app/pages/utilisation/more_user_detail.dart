import 'package:flutter/material.dart';
import 'package:frontend/model/habilitation/user_model.dart';

import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';
import '../../responsitvity/responsivity.dart';

class MoreUserDetail extends StatefulWidget {
  final UserModel user;
  const MoreUserDetail({super.key, required this.user});

  @override
  State<MoreUserDetail> createState() => _MoreUserDetailState();
}

class _MoreUserDetailState extends State<MoreUserDetail> {
  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        0: Responsive.isMobile(context)
            ? const FlexColumnWidth()
            : const FlexColumnWidth(),
      },
      children: [
        ...[
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Nom",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.user.personnel!.nom,
            ),
          ],
        ),
      ],
        ...[
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
                valeur: "Prénoms",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.user.personnel!.prenom,
            ),
          ],
        ),
      ],
        if (widget.user.personnel!.email != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Email",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: widget.user.personnel!.email!,
              ),
            ],
          ),
        ],
        if (widget.user.personnel!.poste != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Poste",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: widget.user.personnel!.poste!,
              ),
            ],
          ),
        ],
        if (widget.user.roles != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Rôle",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: widget.user.roles![0].libelle,
              ),
            ],
          ),
        ],
        if (widget.user.canLogin != null) ...[
          TableRow(
            decoration: tableDecoration(context),
            children: [
              const TabledetailBodyMiddle(
                valeur: "Accès à la plateforme",
                isbold: true,
              ),
              TabledetailBodyMiddle(
                valeur: widget.user.canLogin! ? "Oui" : "Non",
              ),
            ],
          ),
        ],
      ],
    );
  }
}
