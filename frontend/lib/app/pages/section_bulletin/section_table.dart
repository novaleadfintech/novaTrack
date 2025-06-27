import 'package:flutter/material.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/bulletin_paie/section_bulletin.dart';
import '../../../../model/request_response.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../service/section_service.dart';
import '../../../../widget/confirmation_dialog_box.dart';
 
 import '../../../../global/constant/constant.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_last.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../widget/table_header.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
 import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../utils/libelle_flux.dart';
import 'detail_section.dart';
import 'edit_section.dart';

class SectionTable extends StatefulWidget {
  final List<SectionBulletin> section;
  final Future<void> Function() refresh;
  const SectionTable({
    super.key,
    required this.section,
    required this.refresh,
  });

  @override
  State<SectionTable> createState() => _SectionTableState();
}

class _SectionTableState extends State<SectionTable> {
  late SimpleFontelicoProgressDialog _dialog;
  late List<RoleModel> roles = [];
  late Future<void> _futureRoles;

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _futureRoles = getRoles();
    super.initState();
  }

  Future<void> getRoles() async {
    List<RoleModel> roleData = await AuthService().getRoles();
    setState(() {
      roles = roleData;
    });
  }

  editLibelle({
    required SectionBulletin section,
  }) {
    showResponsiveDialog(
      context,
      content: EditSection(
        section: section,
        refresh: widget.refresh,
      ),
      title: "Modifier un section",
    );
  }

  detailSection({required SectionBulletin section}) {
    showDetailDialog(
      context,
      content: DetailSectionPage(
        section: section,
      ),
      title: "Détail de section",
    );
  }

  Future<void> deleteLibelle({
    required SectionBulletin section,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer la section de bulletin \"${section.section}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await SectionService.deleteSection(
        key: section.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Le section a été supprimé avec succcès",
        );
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _futureRoles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erreur de chargement des rôles'));
        } else {
          return buildContent(context);
        }
      },
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        Table(
          columnWidths: {
            0: const FlexColumnWidth(2),
            1: const FixedColumnWidth(50)
          },
          children: [
            tableHeader(
              tablesTitles: sectionTableTitles,
              context,
            )
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                0: const FlexColumnWidth(2),
                1: const FixedColumnWidth(50)
              },
              children: [
                ...widget.section.map(
                  (section) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: section.section,
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailSection(section: section);
                            },
                            color: null, // couleur null
                          ),
                          if (hasPermission(
                            roles: roles,
                            permission: PermissionAlias
                                .updateBulletinSection.label,
                          ))
                            (
                              label: Constant.edit,
                              onTap: () {
                                editLibelle(section: section);
                              },
                              color: null,
                            ),
                          if (hasPermission(
                            roles: roles,
                            permission: PermissionAlias
                                .deleteBulletinSection.label,
                          ))
                            (
                              label: Constant.delete,
                              onTap: () {
                                deleteLibelle(section: section);
                              },
                              color: null,
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
