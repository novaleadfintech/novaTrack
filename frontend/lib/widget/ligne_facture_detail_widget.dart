import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/model/habilitation/role_model.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../app/integration/popop_status.dart';
import '../app/integration/request_frot_behavior.dart';
import '../app/pages/app_dialog_box.dart';
import '../app/pages/detail_pop.dart';
import '../app/pages/facturation/detail_ligne.dart';
import '../app/pages/facturation/facture/add_ligne_facture.dart';
import '../app/pages/facturation/facture/edit_ligne_facture.dart';
import '../app/pages/utils/ligne_service.dart';
import '../app/responsitvity/responsivity.dart';
import '../global/constant/constant.dart';
import '../global/constant/permission_alias.dart';
import '../helper/amout_formatter.dart';
import '../helper/assets/asset_icon.dart';
import '../helper/user_helper.dart';
import '../model/facturation/enum_facture.dart';
import '../model/facturation/facture_model.dart';
import '../model/facturation/ligne_model.dart';
import '../model/pays_model.dart';
import '../model/request_response.dart';
import '../model/service/enum_service.dart';
import '../model/service/service_prix_model.dart';
import '../service/ligne_facture_service.dart';
import '../style/app_style.dart';
import 'confirmation_dialog_box.dart';
import 'subtile_header.dart';
import 'table_body_last.dart';
import 'table_body_middle.dart';

class LigneFactureDetail extends StatefulWidget {
  final FactureModel facture;
  final Future<void> Function() refresh;
  final List<RoleModel> roles;
  const LigneFactureDetail({
    super.key,
    required this.refresh,
    required this.facture,
    required this.roles,
  });

  @override
  State<LigneFactureDetail> createState() => _LigneFactureDetailState();
}

class _LigneFactureDetailState extends State<LigneFactureDetail> {
  late SimpleFontelicoProgressDialog _dialog;
  editLigneFacture({
    required LigneModel ligneFacture,
    required PaysModel pays,
  }) {
    showResponsiveDialog(
      context,
      content: UpdateLigneFacture(
        ligneFacture: ligneFacture,
        pays: pays,
        refresh: widget.refresh,
      ),
      title: "Modifier une demande",
    );
  }

  deleteLigneFacture({
    required LigneModel ligneFacture,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez vous vraiment supprimer le service ${ligneFacture.designation}?",
    );

    if (confirmed) {
      _dialog.show(
        message: "",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await LigneFactureService.retirerLigneFacture(
        ligneFactureId: ligneFacture.id,
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

  _detailLigneFacture({required LigneModel ligneFacture}) {
    showDetailDialog(
      context,
      content: MoreDetailLignePage(
        ligne: ligneFacture,
      ),
      title: "Détail de demande",
    );
  }

  addLigneFacture({
    required FactureModel facture,
  }) async {
    showResponsiveDialog(
      context,
      content: AddLigneFacture(
        facture: facture,
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
          tablesTitles:
              isMobile ? ligneFactureTableTitlesSmall : ligneFactureTableTitles,
          onTap: () async {
            addLigneFacture(
              facture: widget.facture,
            );
          },
          hideButton: (widget.facture.status != StatusFacture.tobepaid ||
                      widget.facture.isConvertFromProforma == true) ||
                  widget.facture.facturesAcompte
                      .any((acompte) => acompte.datePayementEcheante != null) ||
                  !hasPermission(
                      roles: widget.roles,
                      permission: PermissionAlias.updateFacture.label)
              ? true
              : false,
        ),
        ...widget.facture.ligneFactures!.map(
          (ligneFacture) => isMobile
              ? TableRow(
                  decoration: tableDecoration(context),
                  children: [
                    TableBodyMiddle(valeur: ligneFacture.designation),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(ligneFacture.montant),
                    ),
                    TableBodyLast(
                      items: [
                        if ((widget.facture.status == StatusFacture.tobepaid &&
                                widget.facture.isConvertFromProforma != true) &&
                            widget.facture.facturesAcompte.every((acompte) =>
                                acompte.datePayementEcheante == null)) ...[
                          if (hasPermission(
                              roles: widget.roles,
                              permission: PermissionAlias.updateFacture.label))
                          (
                            label: Constant.edit,
                            onTap: () {
                              editLigneFacture(
                                ligneFacture: ligneFacture,
                                pays: widget.facture.client!.pays!,
                              );
                            },
                            color: null,
                          ),
                        ],
                        (
                          label: Constant.detail,
                          onTap: () {
                            _detailLigneFacture(ligneFacture: ligneFacture);
                          },
                          color: null, // couleur null
                        ),
                        if ((widget.facture.status == StatusFacture.tobepaid &&
                                widget.facture.isConvertFromProforma != true) &&
                            widget.facture.facturesAcompte.every((acompte) =>
                                acompte.datePayementEcheante == null)) ...[
                          if (hasPermission(
                              roles: widget.roles,
                              permission: PermissionAlias.updateFacture.label))
                          (
                            label: Constant.delete,
                            onTap: () {
                              deleteLigneFacture(ligneFacture: ligneFacture);
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
                    TableBodyMiddle(valeur: ligneFacture.designation),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(
                          ligneFacture.service!.nature == NatureService.unique
                              ? ligneFacture.service!.prix! +
                                  ligneFacture.prixSupplementaire!
                              : ligneFacture.service!.tarif.firstWhere((tarif) {
                                    if (tarif!.maxQuantity == null) {
                                      return ligneFacture.quantite! >=
                                          tarif.minQuantity;
                                    } else {
                                      return ligneFacture.quantite! >=
                                              tarif.minQuantity &&
                                          ligneFacture.quantite! <=
                                              tarif.maxQuantity!;
                                    }
                                  },
                                      orElse: () => ServiceTarifModel(
                                            minQuantity: 1,
                                            prix: 0,
                                          ))!.prix +
                                  ligneFacture.prixSupplementaire!),
                    ),
                    TableBodyMiddle(valeur: ligneFacture.quantite.toString()),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(ligneFacture.montant),
                    ),
                    Row(
                      children: [
                        if ((widget.facture.status == StatusFacture.tobepaid &&
                                widget.facture.isConvertFromProforma != true) &&
                            widget.facture.facturesAcompte.every((acompte) =>
                                acompte.datePayementEcheante == null))
                          if (hasPermission(
                              roles: widget.roles,
                              permission:
                                  PermissionAlias.updateFacture.label)) ...[
                            IconButton(
                            onPressed: () {
                              editLigneFacture(
                                ligneFacture: ligneFacture,
                                pays: widget.facture.client!.pays!,
                              );
                            },
                            icon: SvgPicture.asset(
                              AssetsIcons.edit,
                            ),
                            ),
                          ],
                          
                        IconButton(
                          onPressed: () {
                            _detailLigneFacture(ligneFacture: ligneFacture);
                          },
                          icon: SvgPicture.asset(
                            AssetsIcons.detail,
                          ),
                        ),
                        if ((widget.facture.status == StatusFacture.tobepaid &&
                                widget.facture.isConvertFromProforma != true) &&
                            widget.facture.facturesAcompte.every((acompte) =>
                                acompte.datePayementEcheante == null))
                          if (hasPermission(
                              roles: widget.roles,
                              permission:
                                  PermissionAlias.updateFacture.label)) ...[
                            IconButton(
                              onPressed: () {
                                deleteLigneFacture(ligneFacture: ligneFacture);
                              },
                              icon: SvgPicture.asset(
                                AssetsIcons.block,
                              ),
                            ),
                          ]
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
