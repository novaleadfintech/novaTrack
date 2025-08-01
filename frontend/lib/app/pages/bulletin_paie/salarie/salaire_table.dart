import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/helper/date_helper.dart';
import 'package:frontend/helper/get_bulletin_period.dart';
import 'package:frontend/model/personnel/personnel_model.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../global/constant/constant.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/assets/asset_icon.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/bulletin_paie/salarie_model.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../model/habilitation/user_model.dart';
import '../../../../model/personnel/enum_personnel.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_last.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../widget/table_header.dart';
import '../../../responsitvity/responsivity.dart';
import '../../app_dialog_box.dart';
import '../../detail_pop.dart';
import '../../utils/personnel_util.dart';
import '../bulletin/add_bulletin.dart';
import 'detail_salarie.dart';
import 'edit_salarie.dart';

class SalarieTable extends StatefulWidget {
  final List<SalarieModel> paginatedPersonnelData;
  final Future<void> Function() refresh;
  const SalarieTable({
    super.key,
    required this.paginatedPersonnelData,
    required this.refresh,
  });

  @override
  State<SalarieTable> createState() => _SalarieTableState();
}

class _SalarieTableState extends State<SalarieTable> {
  late Future<void> _futureRoles;
  late RoleModel role;
  UserModel? currentUser;

  onEdit({required SalarieModel salarie}) {
    showResponsiveDialog(
      context,
      title: "Modifier un salarié",
      content: EditSalariePage(
        salarie: salarie,
        refresh: widget.refresh,
      ),
    );
  }

  onShowDetail({required SalarieModel salarie}) {
    showDetailDialog(
      context,
      content: DetailSalariePage(
        salarie: salarie,
      ),
      title: "Detail du salarié",
      widthFactor: 0.5,
    );
  }

  @override
  void initState() {
    _futureRoles = getRole();
    super.initState();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    return FutureBuilder<void>(
      future: _futureRoles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        return Column(
          children: [
            Table(
              columnWidths: {
                4: const FixedColumnWidth(100),
                2: Responsive.isMobile(context)
                    ? const FixedColumnWidth(50)
                    : const FlexColumnWidth(),
              },
              children: [
                tableHeader(
                  tablesTitles: Responsive.isMobile(context)
                      ? personnelTableTitlesSmall
                      : personnelTableTitles,
                  context,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: isMobile
                    ? Table(
                        columnWidths: {
                          4: const FixedColumnWidth(100),
                          2: Responsive.isMobile(context)
                              ? const FixedColumnWidth(50)
                              : const FlexColumnWidth(),
                        },
                        children: widget.paginatedPersonnelData.map((salarie) {
                          PersonnelModel personnel = salarie.personnel;
                          // bool isCurrentUser =
                          //     personnel.id == currentUser!.personnel!.id;
                          return TableRow(
                            decoration: tableDecoration(context),
                            children: [
                              TableBodyMiddle(valeur: personnel.nom),
                              TableBodyMiddle(
                                  valeur: personnel.poste != null
                                      ? personnel.poste!.libelle
                                      : "Aucun poste"),
                              TableBodyLast(
                                items: [
                                  (
                                    label: Constant.detail,
                                    onTap: () => onShowDetail(salarie: salarie),
                                    color: null,
                                  ),

                                  if (personnel.etat !=
                                          EtatPersonnel.archived &&
                                      hasPermission(
                                        role: role,
                                        permission: PermissionAlias
                                            .createBulletin.label,
                                      ))
                                  (
                                    label: Constant.editerBulletin,
                                    onTap: () =>
                                        onEditBulletin(salarie: salarie),
                                    color: null,
                                  ),

                                  if (personnel.etat != EtatPersonnel.archived
                                           &&
                                      hasPermission(
                                          role: role,
                                          permission: PermissionAlias
                                              .updateSalarie.label) 
                                      ) ...[
                                    (
                                      label: Constant.edit,
                                      onTap: () => onEdit(salarie: salarie),
                                      color: null,
                                    ),
                                  ],

                                  // if (!isCurrentUser &&
                                  //     hasPermission(
                                  //         role: role,
                                  //         permission: PermissionAlias
                                  //             .archivePersonnel.label)) ...[
                                  //   (
                                  //     label: personnel.etat ==
                                  //             EtatPersonnel.archived
                                  //         ? Constant.unarchived
                                  //         : Constant.archived,
                                  //     onTap: () =>
                                  //         archivedOrDesarchivedPersonnel(
                                  //             personnel: personnel),
                                  //     color: null,
                                  //   ),
                                  // ],
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    : Table(
                        columnWidths: {
                          4: const FixedColumnWidth(100),
                          2: Responsive.isMobile(context)
                              ? const FixedColumnWidth(20)
                              : const FlexColumnWidth(),
                        },
                        children: widget.paginatedPersonnelData.map((salarie) {
                          PersonnelModel personnel = salarie.personnel;

                          // bool isCurrentUser =
                          //     personnel.id == currentUser!.personnel!.id;
                          return TableRow(
                            decoration: tableDecoration(context),
                            children: [
                              TableBodyMiddle(valeur: personnel.nom),
                              TableBodyMiddle(valeur: personnel.prenom),
                              TableBodyMiddle(
                                  valeur: personnel.poste != null
                                      ? personnel.poste!.libelle
                                      : "Aucun poste"),
                              TableBodyMiddle(
                                valeur:
                                    "+${personnel.pays!.code} ${personnel.telephone}",
                              ),
                              Row(
                                children: [
                                  if (personnel.etat !=
                                          EtatPersonnel.archived &&
                                      hasPermission(
                                        role: role,
                                        permission: PermissionAlias
                                            .createBulletin.label,
                                      ))
                                  FilledButton(
                                      onPressed: () {
                                        onEditBulletin(salarie: salarie);
                                      },
                                      style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.zero),
                                        shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(4),
                                            ),
                                          ),
                                        ),
                                        textStyle: WidgetStatePropertyAll(
                                          TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      child: SvgPicture.asset(
                                        AssetsIcons.validInvoice,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          BlendMode.srcIn,
                                        ),
                                      )),
                                  TableBodyLast(
                                    items: [
                                      (
                                        label: Constant.detail,
                                        onTap: () =>
                                            onShowDetail(salarie: salarie),
                                        color: null,
                                      ),
                                      if (personnel.etat !=
                                              EtatPersonnel.archived &&
                                          hasPermission(
                                              role: role,
                                              permission: PermissionAlias
                                                  .updateSalarie.label)) ...[
                                        (
                                          label: Constant.edit,
                                          onTap: () => onEdit(salarie: salarie),
                                          color: null,
                                        ),
                                      ],
                                      // if (!isCurrentUser &&
                                      //     hasPermission(
                                      //         role: role,
                                      //         permission: PermissionAlias
                                      //             .archivePersonnel.label)) ...[
                                      //   (
                                      //     label: personnel.etat ==
                                      //             EtatPersonnel.archived
                                      //         ? Constant.unarchived
                                      //         : Constant.archived,
                                      //     onTap: () =>
                                      //         archivedOrDesarchivedPersonnel(
                                      //             personnel: personnel),
                                      //     color: null,
                                      //   ),
                                      // ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  void onEditBulletin({required SalarieModel salarie}) {
    try {
      final todayMidnight = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      if (todayMidnight.isBefore(salarie.personnel.dateDebut!.add(Duration(
              milliseconds: ((salarie.personnel.dureeEssai ?? 0) *
                  (unitMultipliers['mois'] ?? 0))))) ||
          todayMidnight.isAfter(salarie.personnel.dateFin!)) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message:
              "Vous ne pouvez pas éditer un bulletin en dehors de la période du contrat",
        );
      } else {
        List<DateTime>? periode = getCurrentBulletinPeriod(salarie: salarie);
        
        final String titre = periode == null
            ? "Edition du bulletin de paie - ${salarie.personnel.toStringify()}"
            : "Edition du bulletin de paie - ${salarie.personnel.toStringify()} - du ${getStringDate(time: periode.first)} au ${getStringDate(time: periode.last)}";

        final Widget contenu = periode == null
            ? AddBulletinPage(
                salarie: salarie,
                debutPeriodePaie: null,
                finPeriodePaie: null,
              )
            : AddBulletinPage(
                salarie: salarie,
                debutPeriodePaie: periode.first,
                finPeriodePaie: periode.last,
              );

        showResponsiveDialog(
          context,
          title: titre,
          content: contenu,
        );
      }
    } catch (e) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: e.toString());
    }
  }
}
