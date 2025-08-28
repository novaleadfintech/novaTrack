import 'package:flutter/material.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../service/flux_financier_service.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../auth/authentification_token.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../model/request_response.dart';
import '../../../widget/confirmation_dialog_box.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../../../global/constant/constant.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../responsitvity/responsivity.dart';
import '../utils/flux_util.dart';
import 'detail_flux.dart';
import 'edit_flux_page.dart';

class FinanceTable extends StatefulWidget {
  final RoleModel role;

  final List<FluxFinancierModel> fluxFinanciers;
  final Future<void> Function() refresh;
  const FinanceTable({
    super.key,
    required this.role,
    required this.fluxFinanciers,
    required this.refresh,
  });

  @override
  State<FinanceTable> createState() => _InputTableState();
}

class _InputTableState extends State<FinanceTable> {
  UserModel? user;
  late RoleModel role;

  late SimpleFontelicoProgressDialog _dialog;

  Future<void> getCurrentUser() async {
    UserModel? currentUser = await AuthService().decodeToken();
    setState(() {
      user = currentUser;
    });
  }

  editFlux({required FluxFinancierModel flux}) {
    showResponsiveDialog(
      context,
      content: EditFluxFiancierPage(
        flux: flux,
        refresh: widget.refresh,
      ),
      title: "Modifier un flux financier",
    );
  }

  _deleteFlux({required FluxFinancierModel flux}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content: "Voulez-vous vraiment supprimer cette opération financière ?",
    );

    if (!confirmed) {
      return;
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      RequestResponse result =
          await FluxFinancierService.deleteFluxFinancier(key: flux.id);
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.status == PopupStatus.success
            ? "Opération supprimée avec succès."
            : result.message,
      );
      widget.refresh();
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: e.toString(),
      );
    }
  }

  detailFlux({required FluxFinancierModel flux}) {
    showDetailDialog(
      context,
      content: DetailFluxPage(
        flux: flux,
      ),
      title: "Détail de flux financier",
    );
  }

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    getCurrentUser();
    role = widget.role;
    // getRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        Table(
          columnWidths: {
            4: const FixedColumnWidth(50),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(50)
                : const FlexColumnWidth(),
            3: const FixedColumnWidth(180),
            0: const FlexColumnWidth(2)
          },
          children: [
            Responsive.isMobile(context)
                ? tableHeader(
                    tablesTitles: fluxTableTitlesSmall,
                    context,
                  )
                : tableHeader(
                    tablesTitles: fluxTableTitles,
                    context,
                  ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                4: const FixedColumnWidth(50),
                2: Responsive.isMobile(context)
                    ? const FixedColumnWidth(50)
                    : const FlexColumnWidth(),
                3: const FixedColumnWidth(180),
                0: const FlexColumnWidth(2)
              },
              children: [
                ...widget.fluxFinanciers.map(
                  (fluxFinancier) => Responsive.isMobile(context)
                      ? TableRow(
                          decoration:
                              fluxFinancier.status == FluxFinancierStatus.reject
                                  ? rejectFluxTableDecoration(context)
                                  : fluxFinancier.status ==
                                          FluxFinancierStatus.valid
                                      ? validatedFluxTableDecoration(context)
                                      : tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: fluxFinancier.libelle!,
                            ),
                            TableBodyMiddle(
                              valeur:
                                  Formatter.formatAmount(fluxFinancier.montant),
                            ),
                            Stack(
                              children: [
                                TableBodyLast(
                                  items: [
                                    (
                                      label: Constant.detail,
                                      onTap: () {
                                        detailFlux(flux: fluxFinancier);
                                      },
                                      color: null,
                                    ),
                                    if (fluxFinancier.user!
                                            .equalTo(user: user!) &&
                                        (fluxFinancier.status !=
                                            FluxFinancierStatus.valid) &&
                                        !fluxFinancier.isFromSystem! &&
                                        fluxFinancier.factureId == null) ...[
                                      if (hasPermission(
                                          role: role,
                                          permission: PermissionAlias
                                              .updateFluxFinancier.label))
                                        (
                                          label: Constant.edit,
                                          onTap: () {
                                            editFlux(flux: fluxFinancier);
                                          },
                                          color: null, // couleur null
                                        ),
                                      if (hasPermission(
                                              role: role,
                                              permission: PermissionAlias
                                                  .deleteFluxFinancier.label) &&
                                          !fluxFinancier.isFromSystem! &&
                                          fluxFinancier.factureId == null &&
                                          fluxFinancier.status !=
                                              FluxFinancierStatus.wait)
                                        (
                                          label: Constant.delete,
                                          onTap: () {
                                            _deleteFlux(flux: fluxFinancier);
                                          },
                                          color: null, // couleur null
                                        ),
                                    ],
                                  ],
                                ),
                                if (fluxFinancier.status ==
                                    FluxFinancierStatus.returne)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      child: Icon(Icons.message,
                                          color: Colors.red),
                                      onDoubleTap: () {
                                        showMessage(
                                          fluxFinancier: fluxFinancier,
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        )
                      : TableRow(
                          decoration:
                              fluxFinancier.status == FluxFinancierStatus.reject
                                  ? rejectFluxTableDecoration(context)
                                  : fluxFinancier.status ==
                                          FluxFinancierStatus.valid
                                      ? validatedFluxTableDecoration(context)
                                      : tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: fluxFinancier.libelle!,
                            ),
                            TableBodyMiddle(
                              valeur:
                                  Formatter.formatAmount(fluxFinancier.montant),
                            ),
                            TableBodyMiddle(
                              valeur: fluxFinancier.moyenPayement!.libelle,
                            ),
                            TableBodyMiddle(
                              valeur: getStringDate(
                                time: fluxFinancier.dateOperation!,
                              ),
                            ),
                            Stack(
                              children: [
                                TableBodyLast(
                                  items: [
                                    (
                                      label: Constant.detail,
                                      onTap: () {
                                        detailFlux(flux: fluxFinancier);
                                      },
                                      color: null, // couleur null
                                    ),
                                    if (fluxFinancier.user!
                                            .equalTo(user: user!) &&
                                        (fluxFinancier.status !=
                                                FluxFinancierStatus.valid &&
                                            fluxFinancier.status !=
                                                FluxFinancierStatus.reject) &&
                                        !fluxFinancier.isFromSystem! &&
                                        fluxFinancier.factureId == null) ...[
                                      if (hasPermission(
                                          role: role,
                                          permission: PermissionAlias
                                              .updateFluxFinancier.label))
                                        (
                                          label: Constant.edit,
                                          onTap: () {
                                            editFlux(flux: fluxFinancier);
                                          },
                                          color: null,
                                        ),
                                      if (hasPermission(
                                              role: role,
                                              permission: PermissionAlias
                                                  .deleteFluxFinancier.label) &&
                                          !fluxFinancier.isFromSystem! &&
                                          fluxFinancier.factureId == null &&
                                          fluxFinancier.status !=
                                              FluxFinancierStatus.wait)
                                        (
                                          label: Constant.delete,
                                          onTap: () {
                                            _deleteFlux(flux: fluxFinancier);
                                          },
                                          color: null,
                                        ),
                                    ],
                                  ],
                                ),
                                if (fluxFinancier.status ==
                                    FluxFinancierStatus.returne)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      child: Icon(Icons.message,
                                          color: Colors.red),
                                      onDoubleTap: () {
                                        showMessage(
                                          fluxFinancier: fluxFinancier,
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
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

  void showMessage({required FluxFinancierModel fluxFinancier}) {
    MutationRequestContextualBehavior.showPopup(
      status: PopupStatus.customError,
      customMessage: fluxFinancier.validated!.last.commentaire,
    );
  }
}
