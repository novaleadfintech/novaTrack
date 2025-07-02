import 'package:flutter/material.dart';
import 'package:frontend/app/pages/moyen_de_payement/detail_moyen_paiement.dart';
import 'package:frontend/app/pages/moyen_de_payement/edit_moyen_payement.dart';
import 'package:frontend/helper/string_helper.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/service/moyen_paiement_service.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/request_response.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../widget/confirmation_dialog_box.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../utils/libelle_flux.dart';

import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../../../global/constant/constant.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
 
class MoyenPayementTable extends StatefulWidget {
  final List<MoyenPaiementModel> moyenPayementFlux;
  final Future<void> Function() refresh;
  const MoyenPayementTable({
    super.key,
    required this.moyenPayementFlux,
    required this.refresh,
  });

  @override
  State<MoyenPayementTable> createState() => _MoyenPaiementTableState();
}

class _MoyenPaiementTableState extends State<MoyenPayementTable> {
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
    role = await AuthService().getRole();
  }

  editLibelle({
    required MoyenPaiementModel moyenPayement,
  }) {
    showResponsiveDialog(
      context,
      content: EditMoyenPayement(
        moyenPaiement: moyenPayement,
        refresh: widget.refresh,
      ),
      title: "Modifier un moyen de paiement",
    );
  }

  detailMoyenPaiement({required MoyenPaiementModel moyenPaiement}) {
    showDetailDialog(
      context,
      content: DetailMoyenPaiementPage(
        moyenPaiement: moyenPaiement,
      ),
      title: "Détail de moyen de paiement",
    );
  }

  Future<void> deleteLibelle({
    required MoyenPaiementModel moyenPayement,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer le moyen de paiement \"${moyenPayement.libelle}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await MoyenPaiementService.deleteMoyenPaiement(
        key: moyenPayement.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Le moyenPayement a été supprimé avec succcès",
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
              tablesTitles: moyenPaiementTableTitles,
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
                ...widget.moyenPayementFlux.map(
                  (moyenPaiement) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur:
                            capitalizeFirstLetter(word: moyenPaiement.libelle),
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailMoyenPaiement(moyenPaiement: moyenPaiement);
                            },
                            color: null, // couleur null
                          ),
                          if (hasPermission(
                            role: role,
                            permission: PermissionAlias
                                .updateMoyenPaiement.label,
                          ))
                            (
                              label: Constant.edit,
                              onTap: () {
                                editLibelle(moyenPayement: moyenPaiement);
                              },
                              color: null, // couleur null
                            ),
                          if (hasPermission(
                            role: role,
                            permission: PermissionAlias
                                .deleteMoyenPaiement.label,
                          ))
                            (
                              label: Constant.delete,
                              onTap: () {
                                deleteLibelle(moyenPayement: moyenPaiement);
                              },
                              color: null, // couleur null
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
