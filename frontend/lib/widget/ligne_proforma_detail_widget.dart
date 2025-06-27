import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../app/integration/popop_status.dart';
import '../app/integration/request_frot_behavior.dart';
import '../app/pages/app_dialog_box.dart';
import '../app/pages/detail_pop.dart';
import '../app/pages/facturation/detail_ligne.dart';
import '../app/pages/facturation/proforma/add_ligne_proforma.dart';
import '../app/pages/facturation/proforma/edit_ligne_proforma.dart';
import '../app/pages/utils/ligne_service.dart';
import '../app/responsitvity/responsivity.dart';
import '../global/constant/constant.dart';
import '../helper/amout_formatter.dart';
import '../helper/assets/asset_icon.dart';
import '../model/facturation/enum_facture.dart';
import '../model/facturation/ligne_model.dart';
import '../model/facturation/proforma_model.dart';
import '../model/habilitation/role_model.dart';
import '../model/pays_model.dart';
import '../model/request_response.dart';
import '../model/service/enum_service.dart';
import '../model/service/service_prix_model.dart';
import '../service/ligne_proforma_service.dart';
import '../style/app_style.dart';
import 'confirmation_dialog_box.dart';
import 'subtile_header.dart';
import 'table_body_last.dart';
import 'table_body_middle.dart';

class LigneProformaDetail extends StatefulWidget {
  final ProformaModel proforma;
  final Future<void> Function() refresh;
  final List<RoleModel> roles;

  const LigneProformaDetail({
    super.key,
    required this.roles,
    required this.refresh,
    required this.proforma,
  });

  @override
  State<LigneProformaDetail> createState() => _LigneProformaDetailState();
}

class _LigneProformaDetailState extends State<LigneProformaDetail> {
  late SimpleFontelicoProgressDialog _dialog;
  editLigneProforma(
      {required LigneModel ligneProforma, required PaysModel pays}) {
    showResponsiveDialog(
      context,
      content: UpdateLigneProforma(
        ligneProforma: ligneProforma,
        pays: pays,
        refresh: widget.refresh,
      ),
      title: "Modifier une demande",
    );
  }

  deleteLigneProforma({required LigneModel ligneProforma}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez vous vraiment supprimer le service ${ligneProforma.designation}?",
    );

    if (confirmed) {
      _dialog.show(
        message: "",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await LigneProformaService.retirerLigneProforma(
        ligneProformaId: ligneProforma.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Demande enrégistrer avec succès",
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

  _detailLigneProforma({required LigneModel ligneProforma}) {
    showDetailDialog(
      context,
      content: MoreDetailLignePage(
        ligne: ligneProforma,
      ),
      title: "Détail de demande",
    );
  }

  addLigneProforma({
    required String proformaId,
    required PaysModel pays,
  }) {
    showResponsiveDialog(
      context,
      content: AddLigneProforma(
        proformaId: proformaId,
        pays: pays,
        refresh: widget.refresh,
      ),
      title: "Nouvelle demande",
    );
  }

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    // final isTablet = Responsive.isTablet(context);
    return Table(
      columnWidths: {
        5: const IntrinsicColumnWidth(),
        4: const IntrinsicColumnWidth(),
        2: isMobile ? const IntrinsicColumnWidth() : const FlexColumnWidth(),
        1: isMobile ? const IntrinsicColumnWidth() : const FlexColumnWidth(),
        0: isMobile
            ? const FlexColumnWidth(2)
            : const IntrinsicColumnWidth(flex: 2),
      },
      children: [
        subTableHeader(
          context,
          tablesTitles: isMobile
              ? ligneProformaTableTitlesSmall
              : ligneProformaTableTitles,
          onTap: () async {
            addLigneProforma(
              proformaId: widget.proforma.id,
              pays: widget.proforma.client!.pays!,
            );
          },
          hideButton:
              widget.proforma.status != StatusProforma.wait ||
                  !hasPermission(
                      roles: widget.roles,
                      permission: PermissionAlias.updateProforma.label)
              ? true
              : false,
        ),
        ...widget.proforma.ligneProformas!.map(
          (ligneProforma) => isMobile
              ? TableRow(
                  decoration: tableDecoration(context),
                  children: [
                    TableBodyMiddle(valeur: ligneProforma.designation),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(ligneProforma.montant),
                    ),
                    TableBodyLast(
                      items: [
                        if (widget.proforma.status == StatusProforma.wait) ...[
                          if (hasPermission(
                              roles: widget.roles,
                              permission: PermissionAlias.updateProforma.label))
                          (
                            label: Constant.edit,
                            onTap: () {
                              editLigneProforma(
                                ligneProforma: ligneProforma,
                                pays: widget.proforma.client!.pays!,
                              );
                            },
                            color: null,
                          ),
                        ],
                        (
                          label: Constant.detail,
                          onTap: () {
                            _detailLigneProforma(ligneProforma: ligneProforma);
                          },
                          color: null, // couleur null
                        ),
                        if (widget.proforma.status == StatusProforma.wait) ...[
                          if (hasPermission(
                              roles: widget.roles,
                              permission: PermissionAlias.updateProforma.label))
                          (
                            label: Constant.delete,
                            onTap: () {
                              deleteLigneProforma(ligneProforma: ligneProforma);
                            },
                            color: null, // couleur null
                          ),
                        ],
                      ],
                    )
                  ],
                )
              : TableRow(
                  decoration: tableDecoration(context),
                  children: [
                    TableBodyMiddle(valeur: ligneProforma.designation),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(
                          (ligneProforma.service!.nature == NatureService.unique
                                  ? ligneProforma.service!.prix!
                                  : ligneProforma.service!.tarif.firstWhere(
                                      (tarif) {
                                      if (tarif!.maxQuantity == null) {
                                        return ligneProforma.quantite! >=
                                            tarif.minQuantity;
                                      } else {
                                        return ligneProforma.quantite! >=
                                                tarif.minQuantity &&
                                            ligneProforma.quantite! <=
                                                tarif.maxQuantity!;
                                      }
                                    },
                                      orElse: () => ServiceTarifModel(
                                            minQuantity: 1,
                                            prix: 0,
                                          ))!.prix) +
                              ligneProforma.prixSupplementaire!),
                    ),
                    TableBodyMiddle(valeur: ligneProforma.quantite.toString()),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(ligneProforma.montant),
                    ),
                    Row(
                      children: [
                        if (widget.proforma.status == StatusProforma.wait)
                          if (hasPermission(
                              roles: widget.roles,
                              permission:
                                  PermissionAlias.updateProforma.label)) ...[
                            IconButton(
                            onPressed: () {
                              editLigneProforma(
                                ligneProforma: ligneProforma,
                                pays: widget.proforma.client!.pays!,
                              );
                            },
                            icon: SvgPicture.asset(
                              AssetsIcons.edit,
                            ),
                            ),
                          ],
                        IconButton(
                          onPressed: () {
                            _detailLigneProforma(ligneProforma: ligneProforma);
                          },
                          icon: SvgPicture.asset(
                            AssetsIcons.detail,
                          ),
                        ),
                        if (widget.proforma.status == StatusProforma.wait)
                          if (hasPermission(
                              roles: widget.roles,
                              permission:
                                  PermissionAlias.updateProforma.label)) ...[
                            IconButton(
                              onPressed: () {
                                deleteLigneProforma(
                                    ligneProforma: ligneProforma);
                              },
                              icon: SvgPicture.asset(
                                AssetsIcons.block,
                              ),
                            ),
                          ]
                      ],
                    )
                  ],
                ),
        ),
      ],
    );
  }
}
