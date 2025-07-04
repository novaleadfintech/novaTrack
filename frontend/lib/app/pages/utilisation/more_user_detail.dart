import 'package:flutter/material.dart';
import 'package:frontend/helper/date_helper.dart';
import 'package:frontend/model/habilitation/role_enum.dart';
import 'package:frontend/model/habilitation/user_model.dart';

import '../../../style/app_color.dart';
import '../../../style/app_style.dart';
import '../../../widget/app_accordion.dart';
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
    return Column(
      children: [
        Table(
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
                    valeur: widget.user.roles!
                        .map((userRole) => userRole.role.libelle)
                        .join(" --> "),
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
        ),
        if (widget.user.roles != null && widget.user.roles!.isNotEmpty) ...[
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
                            "Rôles",
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
                          widget.user.roles!.length.toString(),
                        ),
                      )
                    ],
                  ),
                  content: Column(
                    children: widget.user.roles!.asMap().entries.map((entry) {
                      int index = entry.key;
                      var userRole = entry.value;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: userRole.roleAuthorization ==
                                          RoleAuthorization.accepted
                                      ? AppColor.greensecondary500
                                      : userRole.roleAuthorization ==
                                              RoleAuthorization.refused
                                          ? AppColor.redColor.withOpacity(0.3)
                                          : AppColor.popGrey,
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    "Rôle ${index + 1}",
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
                                    valeur: userRole.role.libelle,
                                  ),
                                ],
                              ),
                              if (userRole.createBy != null)
                                TableRow(
                                  decoration: tableDecoration(context),
                                  children: [
                                    const TabledetailBodyMiddle(
                                      valeur: "Enrégistré par ",
                                      isbold: true,
                                    ),
                                    TabledetailBodyMiddle(
                                      valeur:
                                          "${userRole.createBy!.personnel!.toStringify()} le ${userRole.timeStamp != null ? getStringDate(time: userRole.timeStamp!) : ""}",
                                    ),
                                  ],
                                ),
                              if (userRole.authorizer != null)
                                TableRow(
                                  decoration: tableDecoration(context),
                                  children: [
                                    const TabledetailBodyMiddle(
                                      valeur: "Autorisé par ",
                                      isbold: true,
                                    ),
                                    TabledetailBodyMiddle(
                                      valeur:
                                          "${userRole.authorizer!.personnel!.toStringify()}, ${userRole.authorizeTime != null ? getStringDate(time: userRole.authorizeTime!) : ""}",
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
  }
}
