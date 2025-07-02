import 'package:flutter/material.dart';
import 'detail_profil.dart';
import 'edit_profil.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../../../global/constant/constant.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../utils/libelle_flux.dart';

class ProfilTable extends StatefulWidget {
  final List<RoleModel> profil;
  final Future<void> Function() refresh;
  const ProfilTable({
    super.key,
    required this.profil,
    required this.refresh,
  });

  @override
  State<ProfilTable> createState() => _ProfilTableState();
}

class _ProfilTableState extends State<ProfilTable> {
  late RoleModel role;
  late Future<void> _futureRoles;

  @override
  void initState() {
    _futureRoles = getRole();
    super.initState();
  }

  Future<void> getRole() async {
    RoleModel currentRole = await AuthService().getRole();
    setState(() {
      role = currentRole;
    });
  }

  editLibelle({
    required RoleModel profil,
  }) {
    showResponsiveDialog(
      context,
      content: EditProfil(
        profil: profil,
        refresh: widget.refresh,
      ),
      title: "Modifier un profil",
    );
  }

  detailProfil({required RoleModel profil}) {
    showDetailDialog(
      context,
      content: DetailProfilPage(
        profil: profil,
      ),
      title: "Détail de profil",
    );
  }

  // Future<void> deleteLibelle({
  //   required RoleModel profil,
  // }) async {
  //   bool confirmed = await handleOperationButtonPress(
  //     context,
  //     content:
  //         "Voulez-vous vraiment supprimer la profil de bulletin \"${profil.libelle}\"?",
  //   );
  //   if (confirmed) {
  //     _dialog.show(
  //       message: '',
  //       type: SimpleFontelicoProgressDialogType.phoenix,
  //       backgroundColor: Colors.transparent,
  //     );

  //     RequestResponse result = await Rol.deleteProfil(
  //       key: profil.id,
  //     );
  //     _dialog.hide();
  //     if (result.status == PopupStatus.success) {
  //       MutationRequestContextualBehavior.showPopup(
  //         status: PopupStatus.success,
  //         customMessage: "Le profil a été supprimé avec succcès",
  //       );
  //       await widget.refresh();
  //     } else {
  //       MutationRequestContextualBehavior.showPopup(
  //         status: result.status,
  //         customMessage: result.message,
  //       );
  //     }
  //   }
  // }

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
              tablesTitles: profilTableTitles,
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
                ...widget.profil.map(
                  (profil) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: profil.libelle.toLowerCase(),
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailProfil(profil: profil);
                            },
                            color: null,
                          ),
                          if (hasPermission(
                            role: role,
                            permission: PermissionAlias.updateRole.label,
                          ))
                            (
                              label: Constant.edit,
                              onTap: () {
                                editLibelle(profil: profil);
                              },
                              color: null,
                            ),
                          // if (!hasPermission(
                          //   role: role,
                          //   permission:
                          //       PermissionAlias.deleteRole.label,
                          // ))
                          //   (
                          //     label: Constant.delete,
                          //     onTap: () {
                          //       deleteLibelle(profil: profil);
                          //     },
                          //     color: null,
                          //   ),
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
