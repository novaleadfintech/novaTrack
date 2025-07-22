import 'package:flutter/material.dart';
import 'package:frontend/helper/string_helper.dart';
import 'package:frontend/style/app_color.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../global/constant/constant.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/user_helper.dart';
import '../../../model/service/enum_service.dart';
import '../../../model/service/service_model.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../service/service_service.dart';
import '../../../style/app_style.dart';
import '../../../widget/confirmation_dialog_box.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../responsitvity/responsivity.dart';
import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../utils/service_util.dart';
import 'duplicate_service_page.dart';
import 'edit_service_page.dart';
import 'more_detail_service.dart';

class ServiceTable extends StatefulWidget {
  final RoleModel role;

  final List<ServiceModel> paginatedServiceData;
  final Future<void> Function() refresh;
  const ServiceTable({
    super.key,
    required this.role,

    required this.paginatedServiceData,
    required this.refresh,
  });

  @override
  State<ServiceTable> createState() => _ServiceTableState();
}

class _ServiceTableState extends State<ServiceTable> {
  late SimpleFontelicoProgressDialog _dialog;
  // late Future<void> _futureRoles;
  late RoleModel role;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    role = widget.role;
    // _futureRoles = getRole();
  }

  // Future<void> getRole() async {
  //   role = await AuthService().getRole();
  // }

  void onEdit({
    required ServiceModel service,
    required Future<void> Function() refresh,
  }) {
    showResponsiveDialog(
      context,
      title: "Modifier un service",
      content: EditServicePage(
        service: service,
        refresh: refresh,
      ),
    );
  }
  void onDuplicate({
    required ServiceModel service,
    required Future<void> Function() refresh,
  }) {
    showResponsiveDialog(
      context,
      title: "Dupliquer un service",
      content: DuplicateServicePage(
        service: service,
        refresh: refresh,
      ),
    );
  }

  void onShowDetail({required ServiceModel service}) {
    showDetailDialog(
      context,
      content: MoreDatailServicePage(
        service: service,
      ),
      title: "Détail du service",
      widthFactor: 0.3,
    );
  }

  Future<void> archivedOrDesarchivedService({
    required ServiceModel service,
  }) async {
    bool isArchived = service.etat == EtatService.archived;
    bool confirmed = await handleOperationButtonPress(
      context,
      content: isArchived
          ? "Voulez-vous vraiment désarchiver le service ${service.libelle}?"
          : "Voulez-vous vraiment archiver le service ${service.libelle}?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      var result = service.etat == EtatService.unarchived
          ? await ServiceService.archivedService(
              serviceId: service.id,
            )
          : await ServiceService.unarchivedService(
              serviceId: service.id,
            );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: isArchived
              ? "Le service a été désarchivé avec succcès"
              : "Le service a été archivé avec succcès",
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
    
    return Column(
      children: [
        Table(
          columnWidths: {
            3: const FixedColumnWidth(50),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(50)
                : const FlexColumnWidth(),
            1: Responsive.isMobile(context)
                ? const IntrinsicColumnWidth(flex: 1)
                : const FlexColumnWidth(),
            0: const FlexColumnWidth(2),
          },
          children: [
            Responsive.isMobile(context)
                ? tableHeader(tablesTitles: servicesTableTitlesSmall, context)
                : tableHeader(tablesTitles: servicesTableTitles, context),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                3: const FixedColumnWidth(50),
                2: Responsive.isMobile(context)
                    ? const FixedColumnWidth(50)
                    : const FlexColumnWidth(),
                1: Responsive.isMobile(context)
                    ? const IntrinsicColumnWidth(flex: 1)
                    : const FlexColumnWidth(),
                0: const FlexColumnWidth(2),
              },
              children: [
                ...widget.paginatedServiceData.map(
                  (service) => Responsive.isMobile(context)
                      ? TableRow(
                          decoration: tableDecoration(context,
                              color: service.type == ServiceType.recurrent
                                  ? AppColor.adaptiveamber(context)
                                  : null),
                          children: [
                            TableBodyMiddle(
                              valeur:
                                  capitalizeFirstLetter(word: service.libelle),
                            ),
                            TableBodyMiddle(
                              valeur:
                                 Formatter.formatAmount(
                                  service.nature == NatureService.multiple
                                      ? service.tarif.first!.prix
                                      : service.prix!),

                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    onShowDetail(service: service);
                                  },
                                  color: null, 
                                ),
                                if (hasPermission(
                                    role: role,
                                    permission:
                                        PermissionAlias.archiveService.label))
                                        (
                                          label: service.etat ==
                                                  EtatService.archived
                                              ? Constant.unarchived
                                              : Constant.archived,
                                          onTap: () {
                                            archivedOrDesarchivedService(
                                              service: service,
                                            );
                                          },
                                          color: null,
                                        ),
                                        if (service.etat !=
                                            EtatService.archived &&
                                    hasPermission(
                                        role: role,
                                        permission: PermissionAlias
                                            .createService.label)) ...[
                                  (
                                    label: Constant.duplicate,
                                    onTap: () => onDuplicate(
                                          service: service,
                                          refresh: widget.refresh,
                                        ),
                                    color: null,
                                  ),
                                ],
                                if (service.etat != EtatService.archived &&
                                    hasPermission(
                                        role: role,
                                        permission: PermissionAlias
                                            .updateService.label)) ...[
                                          (
                                            label: Constant.edit,
                                            onTap: () => onEdit(
                                                  service: service,
                                                  refresh: widget.refresh,
                                                ),

                                            color: null,
                                          ),
                                        ]
                                    
                              ],
                            )
                          ],
                        )
                      : TableRow(
                          decoration: tableDecoration(context,
                              color: service.type == ServiceType.recurrent
                                  ? AppColor.adaptiveamber(context)
                                  : null),
                          children: [
                            TableBodyMiddle(
                              valeur:
                                  capitalizeFirstLetter(word: service.libelle),
                            ),
                            TableBodyMiddle(
                              valeur: Formatter.formatAmount(
                                  service.nature == NatureService.multiple
                                      ? service.tarif.first!.prix
                                      : service.prix!),

                            ),
                            TableBodyMiddle(
                              valeur: service.type!.label,
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    onShowDetail(service: service);
                                  },
                                  color: null, // couleur null
                                ),
                                if (service.etat != EtatService.archived &&
                                    hasPermission(
                                        role: role,
                                        permission: PermissionAlias
                                            .createService.label)) ...[
                                  (
                                    label: Constant.duplicate,
                                    onTap: () => onDuplicate(
                                          service: service,
                                          refresh: widget.refresh,
                                        ),
                                    color: null,
                                  ),
                                ],
                                if (hasPermission(
                                    role: role,
                                    permission:
                                        PermissionAlias.archiveService.label))
                                        (
                                          label: service.etat ==
                                                  EtatService.archived
                                              ? Constant.unarchived
                                              : Constant.archived,
                                          onTap: () {
                                            archivedOrDesarchivedService(
                                              service: service,
                                            );
                                          },
                                          color: null, // couleur null
                                        ),
                                        if (service.etat !=
                                                EtatService.archived &&
                                    hasPermission(
                                        role: role,
                                        permission: PermissionAlias
                                            .updateService.label)) ...[
                                          (
                                            label: Constant.edit,
                                            onTap: () => onEdit(
                                                  service: service,
                                                  refresh: widget.refresh,
                                                ),

                                            color: null, // couleur null
                                          ),
                                        ]
                                     
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
