import 'package:flutter/material.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import '../../../model/request_response.dart';
import '../../../service/libelle_flux_financier_service.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../widget/confirmation_dialog_box.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../utils/libelle_flux.dart';
import '../../../model/flux_financier/libelle_flux.dart';
import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../../../global/constant/constant.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import 'detail_libelle_flux.dart';
import 'edit_libelle_flux_page.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
 
class LibelleFluxTable extends StatefulWidget {
  final List<LibelleFluxModel> libelleFlux;
  final Future<void> Function() refresh;
  const LibelleFluxTable({
    super.key,
    required this.libelleFlux,
    required this.refresh,
  });

  @override
  State<LibelleFluxTable> createState() => _InputTableState();
}

class _InputTableState extends State<LibelleFluxTable> {
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
    roles = await AuthService().getRoles();
  }

  editLibelle({
    required LibelleFluxModel libelle,
  }) {
    showResponsiveDialog(
      context,
      content: EditLibellePage(
        libelleFlux: libelle,
        refresh: widget.refresh,
      ),
      title: libelle.type == FluxFinancierType.input
          ? "Modifier un libellé d'une entrée"
          : "Modifier un libellé d'une sortie",
    );
  }

  detailLibelle({required LibelleFluxModel libelle}) {
    showDetailDialog(
      context,
      content: DetailFluxPage(
        libelleFlux: libelle,
      ),
      title: libelle.type == FluxFinancierType.input
          ? "Détail de libelle d'une entrée financière"
          : "Détail de libelle d'une sortie financière",
    );
  }

  Future<void> deleteLibelle({
    required LibelleFluxModel libelle,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer le libelle \"${libelle.libelle}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result =
          await LibelleFluxFinancierService.deletelibelleFluxFinancier(
        key: libelle.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Le libelle a été supprimé avec succcès",
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
              tablesTitles: libelleFluxTableTitles,
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
                ...widget.libelleFlux.map(
                  (libelleFinancier) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                        
                      TableBodyMiddle(
                        valeur: libelleFinancier.libelle,
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailLibelle(libelle: libelleFinancier);
                            },
                            color: null, // couleur null
                          ),
                          if (hasPermission(
                            roles: roles,
                            permission: PermissionAlias
                                .updateLibelleFluxFinancier.label,
                          ))                    
                                  (
                                    label: Constant.edit,
                                    onTap: () {
                                      editLibelle(libelle: libelleFinancier);
                                    },
                                    color: null, // couleur null
                                  ),
                          if (hasPermission(
                            roles: roles,
                            permission: PermissionAlias
                                .deleteLibelleFluxFinancier.label,
                          ))
                                  (
                                    label: Constant.delete,
                                    onTap: () {
                                      deleteLibelle(libelle: libelleFinancier);
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
