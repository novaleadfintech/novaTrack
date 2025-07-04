import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/pages/facturation/proforma/edit_proformat.dart';
import 'package:frontend/service/proforma_service.dart';
import '../app/integration/popop_status.dart';
import '../app/integration/request_frot_behavior.dart';
import '../app/pages/facturation/proforma/detail_proforma.dart';
import '../app/pdf/facture_generate_and_download/proforma.dart';
import '../app/pages/facturation/proforma/validate_proforma_page.dart';
import '../app/pages/utils/facture_util.dart';
import '../app/responsitvity/responsivity.dart';
 import '../global/constant/constant.dart';
import '../global/constant/permission_alias.dart';
import '../global/constant/request_management_value.dart';
import '../helper/amout_formatter.dart';
import '../helper/assets/asset_icon.dart';
import '../helper/date_helper.dart';
import '../helper/facture_proforma_helper.dart';
import '../helper/user_helper.dart';
import '../model/facturation/enum_facture.dart';
import '../model/facturation/proforma_model.dart';
import '../model/habilitation/role_model.dart';
import '../model/request_response.dart';
import '../style/app_style.dart';
import 'app_accordion.dart';
import 'confirmation_dialog_box.dart';
import 'facture_other_detail.dart';
import 'ligne_proforma_detail_widget.dart';
import 'table_body_last.dart';
import 'table_body_middle.dart';
import 'validate_button.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../app/pages/app_dialog_box.dart';
import '../app/pages/detail_pop.dart';

class ProformaTile extends StatefulWidget {
  final ProformaModel proforma;
  final RoleModel role;
  final Future<void> Function() refresh;
  const ProformaTile({
    super.key,
    required this.refresh,
    required this.proforma,
    required this.role,
  });

  @override
  State<ProformaTile> createState() => _ProformaTileState();
}

class _ProformaTileState extends State<ProformaTile> {
  late SimpleFontelicoProgressDialog _dialog;
  List<String> infoFacture = [];
  late RoleModel role;
  String? errorMessage;

  editProformat({required ProformaModel proforma}) {
    showResponsiveDialog(
      context,
      content: EditProformat(
        proforma: proforma,
        refresh: widget.refresh,
      ),
      title: "Modifier une proforma",
    );
  }

  detailProformat({
    required ProformaModel proforma,
  }) {
    showDetailDialog(
      context,
      content: MoreDetailProformaPage(
        proforma: proforma,
      ),
      title: "Détail de proforma",
    );
  }

  cancelProformat({required ProformaModel proforma}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez vous vraiment annuler le proforma de reference ${proforma.reference}?",
    );

    if (confirmed) {
      _dialog.show(
        message: "",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await ProformaService.updateProformat(
        id: proforma.id,
        statut: StatusProforma.cancel,
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

  downloadProformat({
    required ProformaModel proforma,
  }) async {
    bool confirmed = await handleOperationButtonPress(context,
        content:
            "Voulez-vous obtenir le proforma avec la signature numérique?");
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    try {
      RequestResponse result =
          await ProformaPdfGenerator.generateAndDownloadPdf(
              proforma: proforma, withSignature: confirmed);

      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: "Proforma téléchargé avec succès.",
        );
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
        return;
      }
    } catch (e) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: "Erreur lors du téléchargement",
      );
      return;
    }
  }

  validateProformat({
    required ProformaModel proforma,
  }) {
    if (!hasPermission(
      role: role,
      permission: PermissionAlias.updateFacture.label,
    )) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage: "${RequestMessage.forbidenMessage}valider les proformas",
      );
      return;
    }
    showResponsiveDialog(
      context,
      content: ValidateProformatPage(
        proformaId: proforma.id,
        refresh: widget.refresh,
      ),
      title: "Validation de la proforma",
    );
  }


  @override
  void initState() {
role = widget.role;
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    infoFacture = [
      Formatter.formatAmount(calculerSimpleMontantTotal(
        lignes: widget.proforma.ligneProformas!,
      )),
      Formatter.formatAmount(calculerMontantTotalFraisDivers(
        tauxTVA: widget.proforma.tauxTVA!,
        lignes: widget.proforma.ligneProformas!,
      )),
      Formatter.formatAmount(
        calculerReduction(
          lignes: widget.proforma.ligneProformas!,
          reduction: widget.proforma.reduction!,
        ),
      ),
      Formatter.formatAmount(calculerTva(
        tauxTVA: widget.proforma.tauxTVA!,
        lignes: widget.proforma.ligneProformas!,
        reduction: widget.proforma.reduction!,
        tva: widget.proforma.tva!,
      )),
      Formatter.formatAmount(widget.proforma.montant!),
    ];
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    int emptyCells = isMobile ? 1 : 4;

    return AppAccordion(
      header: isMobile
          ? Table(
              columnWidths: const {
                2: FixedColumnWidth(33),
              },
              children: [
                TableRow(
                  children: [
                    TableBodyMiddle(
                      valeur: widget.proforma.reference,
                    ),
                    TableBodyMiddle(
                      valeur: widget.proforma.client!.toStringify(),
                    ),
                    TableBodyLast(
                      items: [
                        if (widget.proforma.status == StatusProforma.wait) ...[
                          if (hasPermission(
                            role: role,
                            permission: PermissionAlias.validProforma.label,
                          ))
                            (
                              label: Constant.validate,
                              onTap: () {
                                validateProformat(proforma: widget.proforma);
                              },
                              color: null,
                            ),
                        ],
                        (
                          label: Constant.download,
                          onTap: () {
                            downloadProformat(proforma: widget.proforma);
                          },
                          color: null,
                        ),
                        (
                          label: Constant.detail,
                          onTap: () {
                            detailProformat(proforma: widget.proforma);
                          },
                          color: null,
                        ),
                        if (widget.proforma.status == StatusProforma.wait &&
                            (hasPermission(
                              role: role,
                              permission: PermissionAlias.updateProforma.label,
                            )))
                          (
                            label: Constant.edit,
                            onTap: () {
                              editProformat(proforma: widget.proforma);
                            },
                            color: null,
                          ),
                        if (hasPermission(
                              role: role,
                              permission: PermissionAlias.cancelProformat.label,
                            ) &&
                            widget.proforma.status == StatusProforma.wait)
                          (
                            label: Constant.cancel,
                            onTap: () =>
                                cancelProformat(proforma: widget.proforma),
                            color: null,
                          ),
                      ],
                    )
                  ],
                ),
              ],
            )
          : Table(
              columnWidths: {
                4: isTablet
                    ? const FixedColumnWidth(120)
                    : const FixedColumnWidth(175),
                3: isTablet
                    ? const FixedColumnWidth(150)
                    : const FixedColumnWidth(175),
              },
              children: [
                TableRow(
                  children: [
                    TableBodyMiddle(
                      valeur: widget.proforma.reference,
                    ),
                    TableBodyMiddle(
                      valeur: widget.proforma.client!.toStringify(),
                    ),
                    TableBodyMiddle(
                        valeur: getStringDate(
                      time: widget.proforma.dateEtablissementProforma!,
                    )),
                    TableBodyMiddle(
                      valeur: (Formatter.formatAmount(
                        widget.proforma.montant!,
                      )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.proforma.status == StatusProforma.wait) ...[
                          isTablet
                              ? IconButton(
                                  onPressed: () {
                                    validateProformat(
                                      proforma: widget.proforma,
                                    );
                                  },
                                  icon: SvgPicture.asset(
                                    AssetsIcons.validate,
                                  ),
                                )
                              : ValidateButton(
                                  onPressed: () {
                                    validateProformat(
                                      proforma: widget.proforma,
                                    );
                                  },
                                  libelle: "Valider",
                                ),
                        ],
                        if (widget.proforma.status == StatusProforma.wait)
                          IconButton(
                            onPressed: () {
                              downloadProformat(
                                proforma: widget.proforma,
                              );
                            },
                            icon: SvgPicture.asset(
                              AssetsIcons.download,
                            ),
                          )
                        else
                          FilledButton(
                            onPressed: () async {
                              downloadProformat(
                                proforma: widget.proforma,
                              );
                            },
                            style: const ButtonStyle(
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
                            child: isTablet
                                ? SvgPicture.asset(
                                    AssetsIcons.download,
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.onPrimary,
                                      BlendMode.srcIn,
                                    ),
                                  )
                                : const Text(
                                    Constant.download,
                                  ),
                          ),
                        TableBodyLast(
                          items: [
                            if (widget.proforma.status ==
                                StatusProforma.wait) ...[
                              if (hasPermission(
                                role: role,
                                permission:
                                    PermissionAlias.updateProforma.label,
                              ))
                                (
                                  label: Constant.edit,
                                  onTap: () =>
                                      editProformat(proforma: widget.proforma),
                                  color: null,
                                ),
                              if (hasPermission(
                                role: role,
                                permission:
                                    PermissionAlias.cancelProformat.label,
                              ))
                                (
                                  label: Constant.cancel,
                                  onTap: () => cancelProformat(
                                      proforma: widget.proforma),
                                  color: null,
                                ),
                            ],
                            (
                              label: Constant.detail,
                              onTap: () =>
                                  detailProformat(proforma: widget.proforma),
                              color: null,
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LigneProformaDetail(
            role: role,
            refresh: widget.refresh,
            proforma: widget.proforma,
          ),
          Table(
            columnWidths: {
              5: const IntrinsicColumnWidth(),
              2: isMobile
                  ? const IntrinsicColumnWidth()
                  : const FlexColumnWidth()
            },
            children: proformaInfo.asMap().entries.map((entry) {
              int index = entry.key;
              String value = entry.value;

              return factureOtherDelailTableRow(
                emptyCells: emptyCells,
                decoration: tableDecoration(context),
                value: (
                  value,
                  infoFacture[index],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
