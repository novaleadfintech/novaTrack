import 'package:flutter/material.dart';
import 'package:frontend/helper/string_helper.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/request_response.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../widget/confirmation_dialog_box.dart';

import '../../../../global/constant/constant.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_last.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../widget/table_header.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../model/personnel/poste_model.dart';
import '../../../service/poste_service.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../utils/libelle_flux.dart';
import 'detail_poste.dart';
import 'edit_poste.dart';

class PosteTable extends StatefulWidget {
  final List<PosteModel> poste;
  final Future<void> Function() refresh;
  const PosteTable({
    super.key,
    required this.poste,
    required this.refresh,
  });

  @override
  State<PosteTable> createState() => _PosteTableState();
}

class _PosteTableState extends State<PosteTable> {
  late SimpleFontelicoProgressDialog _dialog;
  late RoleModel role;
  late Future<void> _futureRoles;

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
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
    required PosteModel poste,
  }) {
    showResponsiveDialog(
      context,
      content: EditPoste(
        poste: poste,
        refresh: widget.refresh,
      ),
      title: "Modifier un poste",
    );
  }

  detailPoste({required PosteModel poste}) {
    showDetailDialog(
      context,
      content: DetailPostePage(
        poste: poste,
      ),
      title: "Détail de poste",
    );
  }

  Future<void> deletePoste({
    required PosteModel poste,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer la poste de bulletin \"${poste.libelle}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await PosteService.deletePoste(
        key: poste.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Le poste a été supprimé avec succcès",
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
              tablesTitles: posteTableTitles,
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
                ...widget.poste.map(
                  (poste) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: capitalizeFirstLetter(word: poste.libelle),
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailPoste(poste: poste);
                            },
                            color: null, // couleur null
                          ),
                          if (hasPermission(
                            role: role,
                            permission: PermissionAlias.updatePoste.label,
                          ))
                            (
                              label: Constant.edit,
                              onTap: () {
                                editLibelle(poste: poste);
                              },
                              color: null,
                            ),
                          // if (hasPermission(
                          //   role: role,
                          //   permission: PermissionAlias
                          //       .deletePoste.label,
                          // ))
                          //   (
                          //     label: Constant.delete,
                          //     onTap: () {
                          //       deleteLibelle(poste: poste);
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
