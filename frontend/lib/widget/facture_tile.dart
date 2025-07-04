import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/pages/facturation/facture/edit_facture_accompte.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/global/constant/request_management_value.dart';
import 'package:frontend/helper/date_helper.dart';
import 'package:frontend/style/app_color.dart';
import 'package:frontend/widget/affiche_information_on_pop_pop.dart';
import 'package:frontend/widget/clickable_tile.dart';
import 'package:frontend/widget/duration_field.dart';
import 'package:gap/gap.dart';
import '../app/pages/app_dialog_box.dart';
import '../app/pages/detail_pop.dart';
import '../app/pages/facturation/facture/detail_facture.dart';
import '../app/pdf/facture_generate_and_download/facture_acompte.dart';
import '../helper/user_helper.dart';
import '../model/habilitation/role_model.dart';
import '../service/facture_service.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../app/integration/popop_status.dart';
import '../app/integration/request_frot_behavior.dart';
import '../app/pages/facturation/facture/edit_facture.dart';
import '../app/pdf/facture_generate_and_download/facture.dart';
import '../app/pages/utils/facture_util.dart';
import '../app/responsitvity/responsivity.dart';
import '../global/constant/constant.dart';
import '../helper/amout_formatter.dart';
import '../helper/assets/asset_icon.dart';
import '../helper/facture_proforma_helper.dart';
import '../model/facturation/enum_facture.dart';
import '../model/facturation/facture_model.dart';
import '../model/request_response.dart';
import '../style/app_style.dart';
import 'app_accordion.dart';
import 'confirmation_dialog_box.dart';
import 'facture_other_detail.dart';
import 'ligne_facture_detail_widget.dart';
import 'table_body_last.dart';
import 'table_body_middle.dart';
import 'validate_button.dart';

class FactureTile extends StatefulWidget {
  final RoleModel role;

  final Future<void> Function() refresh;
  final FactureModel facture;

  const FactureTile({
    super.key,
    required this.role,
    required this.refresh,
    required this.facture,
  });

  @override
  State<FactureTile> createState() => _FactureTileState();
}

class _FactureTileState extends State<FactureTile> {
  late SimpleFontelicoProgressDialog _dialog;
  String? unit;
  final TextEditingController _compterController = TextEditingController();
  DateTime? delaisPayement;
  TextEditingController delaisController = TextEditingController();
  late RoleModel role;

  // Future<void> getRole() async {
  //   RoleModel currentRole = await AuthService().getRole();
  //   setState(() {
  //     role = currentRole;
  //   });
  // }

  _editFacture({
    required FactureModel facture,
  }) {
    showResponsiveDialog(
      context,
      content: EditFacture(
        facture: facture,
        refresh: widget.refresh,
      ),
      title: "Modifier une facture",
    );
  }

  void _editPartialPaidFacture({required FactureModel facture}) {
    // Filtrer les factures d'acompte modifiables
    final acomptesModifiables = facture.facturesAcompte
        .where((acompte) => acompte.isPaid != true)
        .toList();
    if (acomptesModifiables.isEmpty) {
      showResponsiveDialog(
        context,
        content: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              "Aucune facture d'acompte modifiable.",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        title: "Modifier une facture d'acompte",
      );
    } else {
      // Afficher la liste des factures d'acompte modifiables
      showResponsiveDialog(
        context,
        content: Column(children: [
          ShowInformation(
              content: widget.facture.client!.toStringify(), libelle: "Client"),
          ShowInformation(
            content: widget.facture.reference,
            libelle: "Référence",
          ),
          ...acomptesModifiables.map((acompte) {
            return acompte.isPaid != true
                ? ClickabeTile(
                    title: "Facture d'acompte N°${acompte.rang}",
                    onTap: () {
                      showResponsiveDialog(
                        context,
                        content: EditFactureAccompte(
                          role: role,
                          refresh: widget.refresh,
                          factureAcompte: acompte,
                          dateEtablissement: facture.dateEtablissementFacture!,
                          factureId: widget.facture.id,
                        ),
                        title:
                            "Modifier la facture d'acompte N°${acompte.rang}",
                      );
                    },
                  )
                : SizedBox();
          }),
        ]),
        title: "Modifier une facture d'acompte",
      );
    }
  }

  _detailFacture({
    required FactureModel facture,
  }) {
    showDetailDialog(
      context,
      content: MoreDetailFacturePage(
        facture: facture,
      ),
      title: "Détail de facture",
    );
  }

  _deleteFacture({required FactureModel facture}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer la facture N° ${facture.reference} de ${facture.client!.toStringify()}?",
    );

    if (!confirmed) {
      // Si l'utilisateur annule, on ne fait rien.
      return;
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      RequestResponse result =
          await FactureService.deleteFacture(factureId: facture.id);
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.status == PopupStatus.success
            ? "Facture supprimée avec succès."
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

  _downloadFacture({required FactureModel facture}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content: "Voulez-vous obtenir la facture avec la signature numérique?",
    );

    // if (!confirmed) {
    //   // Si l'utilisateur annule, on ne fait rien.
    //   return;
    // }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      RequestResponse result = await FacturePdfGenerator.generateAndDownloadPdf(
        facture: facture,
        withSignature: confirmed,
      );

      _dialog.hide();

      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.status == PopupStatus.success
            ? "Facture téléchargée avec succès."
            : result.message,
      );
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: "Erreur lors du téléchargement",
      );
    }
  }

  _downloadFactureAcompte({
    required FactureModel facture,
    required int rang,
  }) async {
    DateTime onlyDate = DateTime.now();
    // DateTime onlyDate = DateTime(now.year, now.month, now.day);
    // print(facture.facturesAcompte[rang - 1].dateEnvoieFacture);
    // print(onlyDate);
    if (facture.facturesAcompte[rang - 1].dateEnvoieFacture.isAfter(onlyDate)) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message:
            "L'obtention de cette facture d'acompte N° $rang ne sera possible qu'à partir du ${getStringDate(time: facture.facturesAcompte[rang - 1].dateEnvoieFacture)}",
      );
      return;
    }
    bool withSignature = false;

    bool hasUnpaidPrevious = facture.facturesAcompte.any((factureAcompte) =>
        factureAcompte.rang < rang &&
        factureAcompte.datePayementEcheante == null);

    if (hasUnpaidPrevious) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message:
            "Vous n'avez pas encore gérer la facture d'acompte qui précède cette dernière",
      );
      return;
    }

    if (facture.facturesAcompte[rang - 1].datePayementEcheante == null) {
      bool updateSuccess = await _updateDelaiPayementAndDownload(
        rang: rang,
        facture: facture,
      );
      if (!updateSuccess) return;
    } else {
      withSignature = await confimWidget();
      await _downloadFactureAccompte(
        rang: rang,
        withSignature: withSignature,
      );
    }
  }

  Future<bool> _updateDelaiPayementAndDownload({
    required int rang,
    required FactureModel facture,
  }) async {
    Completer<bool> completer = Completer<bool>();
    setState(() {
      if (widget.facture.delaisPayment != null) {
        _compterController.text = convertDuration(
          durationMs: widget.facture.delaisPayment!,
        ).compteur.toString();
        unit = convertDuration(
          durationMs: widget.facture.delaisPayment!,
        ).unite;
      } else {
        _compterController.text = '';
        unit = null;
      }
    });
    showResponsiveDialog(
      context,
      content: Column(
        children: [
          DurationField(
            label: "Délai de paiement",
            onUnityChanged: (value) {
              setState(
                () {
                  unit = value;
                },
              );
            },
            unitSelectItem: unit,
            controller: _compterController,
          ),
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ValidateButton(
                libelle: "Suivant",
                onPressed: () async {
                  int? compteur = int.tryParse(_compterController.text);
                  if ((compteur != null && unit == null) ||
                      compteur == null && unit != null) {
                    MutationRequestContextualBehavior.showPopup(
                      status: PopupStatus.customError,
                      customMessage:
                          "Veuillez remplir les deux champs de durée de livraison.",
                    );
                    return;
                  }
                  delaisPayement = (DateTime.now()
                              .subtract(Duration(
                                  hours: DateTime.now().hour,
                                  minutes: DateTime.now().minute))
                              .isBefore(facture
                                  .facturesAcompte[rang - 1].dateEnvoieFacture)
                          ? facture.facturesAcompte[rang - 1].dateEnvoieFacture
                          : DateTime.now())
                      .add(
                    Duration(
                      milliseconds: compteur! * unitMultipliers[unit!]!,
                    ),
                  );

                  _dialog.show(
                    message: "",
                    type: SimpleFontelicoProgressDialogType.phoenix,
                    backgroundColor: Colors.transparent,
                  );
                  try {
                    RequestResponse result =
                        await FactureService.updateFactureAccompte(
                      datePayementEcheante: delaisPayement!,
                      factureId: widget.facture.id,
                      rang: rang,
                    );
                    if (result.status == PopupStatus.success) {
                      completer.complete(true);
                      bool withSignature = await confimWidget();
                      MutationRequestContextualBehavior.closePopup();
                      MutationRequestContextualBehavior.closePopup();
                      await _downloadFactureAccompte(
                        rang: rang,
                        withSignature: withSignature,
                        dalaiPayement: delaisPayement,
                      );
                      widget.refresh();
                    } else {
                      MutationRequestContextualBehavior.showPopup(
                        status: result.status,
                        customMessage: result.message,
                      );
                      completer.complete(false);
                    }
                  } catch (e) {
                    MutationRequestContextualBehavior.closePopup();
                    MutationRequestContextualBehavior.showPopup(
                      status: PopupStatus.customError,
                      customMessage:
                          "Erreur lors de la mise à jour du délai de paiement.",
                    );
                    completer.complete(false);
                  } finally {
                    _dialog.hide();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      title:
          "Veuillez renseigner le délai de paiement de la facture d'acompte N°$rang",
    );

    return completer.future;
  }

  Future<void> _downloadFactureAccompte({
    required int rang,
    required bool withSignature,
    DateTime? dalaiPayement,
  }) async {
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      RequestResponse downloadResult =
          await FactureAcomptePdfGenerator.generateAndDownloadPdf(
        facture: widget.facture,
        rang: rang,
        withSignature: withSignature,
        delaisPayement: delaisPayement,
      );
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: downloadResult.status,
        customMessage: downloadResult.status == PopupStatus.success
            ? "Facture téléchargée avec succès."
            : downloadResult.message,
      );
    } catch (e) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: "Erreur lors du téléchargement de la facture.",
      );
    } finally {
      _dialog.hide();
    }
  }

  Future<bool> confimWidget() async {
    return await handleOperationButtonPress(
      context,
      content: "Voulez-vous obtenir la facture avec la signature numérique?",
    );
  }

  int rappelRang = 0;
  late List<String> infoFacture;

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
        lignes: widget.facture.ligneFactures!,
      )),
      Formatter.formatAmount(calculerMontantTotalFraisDivers(
        tauxTVA: widget.facture.tauxTVA!,
        lignes: widget.facture.ligneFactures!,
      )),
      Formatter.formatAmount(
        calculerReduction(
          lignes: widget.facture.ligneFactures!,
          reduction: widget.facture.reduction!,
        ),
      ),
      Formatter.formatAmount(
        calculerTva(
          tauxTVA: widget.facture.tauxTVA!,
          lignes: widget.facture.ligneFactures!,
          reduction: widget.facture.reduction!,
          tva: widget.facture.tva!,
        ),
      ),
      Formatter.formatAmount((widget.facture.facturesAcompte.fold(
            0.0,
            (sum, acompte) =>
                sum! +
                (acompte.oldPenalties?.fold(0.0, (s, p) => s! + p.montant) ??
                    0.0),
          ) ??
          0.0)),
      Formatter.formatAmount(widget.facture.montant! +
          (widget.facture.facturesAcompte.fold(
                0.0,
                (sum, acompte) =>
                    sum! +
                    (acompte.oldPenalties
                            ?.fold(0.0, (s, p) => s! + p.montant) ??
                        0.0),
              ) ??
              0.0)),
    ];

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    int emptyCells = isMobile ? 1 : 4;

    return Stack(
      children: [
        AppAccordion(
          header: isMobile
              ? Column(
                  children: [
                    Table(
                      columnWidths: const {
                        2: FixedColumnWidth(33),
                      },
                      children: [
                        TableRow(
                          children: [
                            TableBodyMiddle(
                              valeur: widget.facture.reference,
                            ),
                            TableBodyMiddle(
                              valeur: widget.facture.client!.toStringify(),
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.download,
                                  onTap: () async {
                                    await _downloadFacture(
                                      facture: widget.facture,
                                    );
                                  },
                                  color: null, // couleur null
                                ),
                                if (widget.facture.status !=
                                        StatusFacture.paid ||
                                    ((widget.facture.regenerate == true &&
                                        widget.facture.isDeletable ==
                                            true))) ...[
                                  if (hasPermission(
                                    role: role,
                                    permission:
                                        PermissionAlias.updateFacture.label,
                                  ))
                                    (
                                      label: Constant.edit,
                                      onTap: (widget.facture.status ==
                                                      StatusFacture.tobepaid &&
                                                  !widget.facture
                                                      .isConvertFromProforma!) &&
                                              widget.facture.facturesAcompte
                                                  .every((acompte) =>
                                                      acompte
                                                          .datePayementEcheante ==
                                                      null)
                                          ? () {
                                              _editFacture(
                                                  facture: widget.facture);
                                            }
                                          : () {
                                              _editPartialPaidFacture(
                                                  facture: widget.facture);
                                            },
                                      color: null,
                                    ),
                                ],
                                if (widget.facture.status ==
                                        StatusFacture.tobepaid &&
                                    !widget.facture.isConvertFromProforma!) ...[
                                  if (widget.facture.type !=
                                          TypeFacture.recurrent &&
                                      widget.facture.isDeletable != true &&
                                      widget.facture.facturesAcompte.every(
                                          (acompte) =>
                                              acompte.datePayementEcheante ==
                                              null)) ...[
                                    if (hasPermission(
                                      role: role,
                                      permission:
                                          PermissionAlias.deleteFacture.label,
                                    ))
                                      (
                                        label: Constant.delete,
                                        onTap: () {
                                          _deleteFacture(
                                              facture: widget.facture);
                                        },
                                        color: null,
                                      ),
                                  ],
                                ],
                                if (widget.facture.status !=
                                        StatusFacture.paid &&
                                    widget.facture.isDeletable != true)
                                  ...widget.facture.facturesAcompte
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => (
                                          label: widget.facture.regenerate ==
                                                  true
                                              ? "Obtenir la facture"
                                              : "Obtenir une facture d'acompte #${entry.value.rang}",
                                          onTap: () async {
                                            await _downloadFactureAcompte(
                                              facture: widget.facture,
                                              rang: entry.value.rang,
                                            );
                                          },
                                          color: entry.value
                                                      .datePayementEcheante !=
                                                  null
                                              ? AppColor.grayColor
                                              : null,
                                        ),
                                      ),
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    _detailFacture(facture: widget.facture);
                                  },
                                  color: null,
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    Table(
                      columnWidths: {
                        4: isTablet
                            ? const FixedColumnWidth(128)
                            : const FixedColumnWidth(175),
                        2: const FlexColumnWidth(),
                        3: const FixedColumnWidth(150),
                      },
                      children: [
                        TableRow(
                          children: [
                            TableBodyMiddle(
                              valeur: widget.facture.reference,
                            ),
                            TableBodyMiddle(
                              valeur: widget.facture.client!.toStringify(),
                            ),
                            TableBodyMiddle(
                              valeur: widget.facture.status!.label,
                            ),
                            TableBodyMiddle(
                              valeur: Formatter.formatAmount(
                                  (widget.facture.montant! +
                                      widget.facture.facturesAcompte.fold(
                                        0.0,
                                        (sum, acompte) =>
                                            sum +
                                            (acompte.oldPenalties?.fold(0.0,
                                                    (s, p) => s! + p.montant) ??
                                                0.0),
                                      ))),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FilledButton(
                                  onPressed: () async {
                                    await _downloadFacture(
                                      facture: widget.facture,
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
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            BlendMode.srcIn,
                                          ),
                                        )
                                      : Text(Constant.download),
                                ),
                                TableBodyLast(
                                  items: [
                                    if (widget.facture.status !=
                                            StatusFacture.paid ||
                                        (widget.facture.regenerate == true &&
                                            widget.facture.isDeletable ==
                                                true)) ...[
                                      if (hasPermission(
                                        role: role,
                                        permission:
                                            PermissionAlias.updateFacture.label,
                                      ))
                                        (
                                          label: Constant.edit,
                                          onTap: (widget.facture.status ==
                                                          StatusFacture
                                                              .unpaid &&
                                                      !widget.facture
                                                          .isConvertFromProforma!) &&
                                                  widget.facture.facturesAcompte
                                                      .every((acompte) =>
                                                          acompte
                                                              .datePayementEcheante ==
                                                          null)
                                              ? () {
                                                  _editFacture(
                                                      facture: widget.facture);
                                                }
                                              : () {
                                                  _editPartialPaidFacture(
                                                      facture: widget.facture);
                                                },
                                          color: null,
                                        ),
                                    ],
                                    if (widget.facture.status ==
                                            StatusFacture.tobepaid &&
                                        !widget.facture
                                            .isConvertFromProforma!) ...[
                                      if (hasPermission(
                                        role: role,
                                        permission:
                                            PermissionAlias.deleteFacture.label,
                                      ))
                                        if (widget.facture.type !=
                                                TypeFacture.recurrent &&
                                            widget.facture.isDeletable !=
                                                true &&
                                            widget.facture.facturesAcompte
                                                .every((acompte) =>
                                                    acompte
                                                        .datePayementEcheante ==
                                                    null)) ...[
                                          (
                                            label: Constant.delete,
                                            onTap: () {
                                              _deleteFacture(
                                                  facture: widget.facture);
                                            },
                                            color: null,
                                          ),
                                        ],
                                    ],
                                    if (widget.facture.status !=
                                            StatusFacture.paid &&
                                        widget.facture.isDeletable != true) ...[
                                      ...widget.facture.facturesAcompte
                                          .asMap()
                                          .entries
                                          .map(
                                            (entry) => (
                                              label: widget
                                                          .facture.regenerate ==
                                                      true
                                                  ? "Obtenir la facture"
                                                  : "Obtenir une facture d'acompte #${entry.value.rang}",
                                              onTap: () async {
                                                await _downloadFactureAcompte(
                                                  facture: widget.facture,
                                                  rang: entry.value.rang,
                                                );
                                              },
                                              color: entry.value
                                                          .datePayementEcheante !=
                                                      null
                                                  ? AppColor.popGrey
                                                  : null,
                                            ),
                                          ),
                                    ],
                                    (
                                      label: Constant.detail,
                                      onTap: () {
                                        _detailFacture(facture: widget.facture);
                                      },
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
                  ],
                ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LigneFactureDetail(
                facture: widget.facture,
                refresh: widget.refresh,
                role: role,
              ),
              Table(
                columnWidths: {
                  5: const IntrinsicColumnWidth(),
                  2: isMobile
                      ? const IntrinsicColumnWidth()
                      : const FlexColumnWidth(),
                },
                children: factureInfo.asMap().entries.map((entry) {
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
        ),
        if (widget.facture.regenerate == true || widget.facture.blocked == true)
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onDoubleTap: () {
                widget.facture.blocked!
                    ? restartService(facture: widget.facture)
                    : arrestService(
                        facture: widget.facture,
                      );
              },
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.facture.blocked! ? "Stopper" : "À régénérer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        if (widget.facture.isDeletable != true &&
            widget.facture.facturesAcompte.any((accompte) {
              if (accompte.datePayementEcheante == null &&
                  (duration(date: accompte.dateEnvoieFacture) == "Demain" ||
                      duration(date: accompte.dateEnvoieFacture) ==
                          "Aujourd'hui")) {
                setState(() {
                  rappelRang = accompte.rang;
                });
                return true;
              }

              if (accompte.datePayementEcheante == null &&
                  accompte.dateEnvoieFacture.isBefore(DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day))) {
                setState(() {
                  rappelRang = accompte.rang;
                });
                return true;
              }
              return false;
            })) ...[
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                duration(
                                date: widget
                                    .facture
                                    .facturesAcompte[rappelRang - 1]
                                    .dateEnvoieFacture) ==
                            "Demain" ||
                        duration(
                                date: widget
                                    .facture
                                    .facturesAcompte[rappelRang - 1]
                                    .dateEnvoieFacture) ==
                            "Aujourd'hui"
                    ? "${shortDuration(date: widget.facture.facturesAcompte[rappelRang - 1].dateEnvoieFacture)} : $rappelRang"
                    : "#$rappelRang",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  void arrestService({required FactureModel facture}) async {
    if (!hasPermission(
      role: role,
      permission: PermissionAlias.stopFactureGeneration.label,
    )) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage:
            "${RequestMessage.forbidenMessage}stopper la regéneration des factures",
      );
      return;
    }
    bool? confirmed = await handleOperationButtonPress(context,
        content:
            "Voulez vous vraiment arreter la regénération de cette facture de ${facture.client!.toStringify()}?");
    if (confirmed) {
      _dialog.show(message: "Arrêt en cours");
      RequestResponse result = await FactureService.stoppregeneration(
          secreteKey: facture.secreteKey!);
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
            status: result.status,
            customMessage: "Regeneration arrêté avec succès!");
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    }
  }

  void restartService({required FactureModel facture}) async {
    if (!hasPermission(
      role: role,
      permission: PermissionAlias.stopFactureGeneration.label,
    )) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage:
            "${RequestMessage.forbidenMessage}redemarrer la regéneration des factures",
      );
      return;
    }
    bool? confirmed = await handleOperationButtonPress(context,
        content:
            "Voulez vous vraiment redemarrer la regénération de cette facture de ${facture.client!.toStringify()}?");
    if (confirmed) {
      _dialog.show(message: "En cours");
      RequestResponse result =
          await FactureService.startregeneration(facture: facture);
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
            status: result.status,
            customMessage: "Regeneration activée avec succès!");
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    }
  }
}
