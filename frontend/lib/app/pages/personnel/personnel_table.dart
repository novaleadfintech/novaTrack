import 'package:flutter/material.dart';
import '../../../auth/authentification_token.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../model/personnel/enum_personnel.dart';
import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../error_page.dart';
import 'edit_personnel_page.dart';
import 'more_detail_personnel.dart';
import '../utils/personnel_util.dart';
import '../../responsitvity/responsivity.dart';
import '../../../global/constant/constant.dart';
import '../../../model/personnel/personnel_model.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../service/personnel_service.dart';
import '../../../widget/confirmation_dialog_box.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class PersonnelTable extends StatefulWidget {
  final RoleModel role;

  final List<PersonnelModel> paginatedPersonnelData;
  final Future<void> Function() refresh;
  const PersonnelTable({
    super.key,
    required this.role,
    required this.paginatedPersonnelData,
    required this.refresh,
  });

  @override
  State<PersonnelTable> createState() => _PersonnelTableState();
}

class _PersonnelTableState extends State<PersonnelTable> {
  late SimpleFontelicoProgressDialog _dialog;
  // late Future<void> _futureRoles;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  late RoleModel role;
  UserModel? currentUser;

  onEdit({required PersonnelModel personnel}) {
    showResponsiveDialog(
      context,
      title: "Modifier un personnel",
      content: EditPersonnelPage(
        personnel: personnel,
        refresh: widget.refresh,
      ),
    );
  }

  onShowDetail({required PersonnelModel personnel}) {
    showDetailDialog(
      context,
      content: MoreDatailPersonnelPage(
        personnel: personnel,
      ),
      title: "Detail du personnel",
      widthFactor: 0.5,
    );
  }

  Future<void> archivedOrDesarchivedPersonnel({
    required PersonnelModel personnel,
  }) async {
    bool isArchived = personnel.etat == EtatPersonnel.archived;
    bool confirmed = await handleOperationButtonPress(
      context,
      content: isArchived
          ? "Voulez-vous vraiment désarchiver le personnel ${personnel.nom} ${personnel.prenom}?"
          : "Voulez-vous vraiment archiver le personnel ${personnel.nom} ${personnel.prenom}?",
    );

    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );
      var result = isArchived
          ? await PersonnelService.unArchivedPersonnel(
              personnelId: personnel.id)
          : await PersonnelService.archivedPersonnel(personnelId: personnel.id);
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: isArchived
              ? "Le personnel a été désarchivé avec succès"
              : "Le personnel a été archivé avec succès",
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
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    role = widget.role;
    // _futureRoles = getRole();
    getCurrentUser();
    super.initState();
  }

  // Future<void> getRole() async {
  //   role = await AuthService().getRole();
  // }

  Future<void> getCurrentUser() async {
    try {
      setState(() {
        isLoading = true;
      });
      UserModel? curUser = await AuthService().decodeToken();
      setState(() {
        currentUser = curUser;
      });
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      setState(() {
        isLoading = false;
        hasError = errorMessage != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return ErrorPage(
        message: errorMessage ?? "Une erreur s'est produite",
        onPressed: () async {
          setState(() {
            isLoading = true;
            hasError = false;
          });
          await getCurrentUser();
        },
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
          },
          children: [
            tableHeader(
              tablesTitles: Responsive.isMobile(context)
                  ? personnelTableTitlesSmall
                  : personnelTableTitles,
              context,
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: isMobile
                ? Table(
                    columnWidths: {
                      4: const FixedColumnWidth(50),
                      2: Responsive.isMobile(context)
                          ? const FixedColumnWidth(50)
                          : const FlexColumnWidth(),
                    },
                    children: widget.paginatedPersonnelData.map((personnel) {
                      bool isCurrentUser =
                          personnel.id == currentUser!.personnel!.id;
                      return TableRow(
                        decoration: tableDecoration(context),
                        children: [
                          TableBodyMiddle(valeur: personnel.nom),
                          TableBodyMiddle(
                              valeur: personnel.poste != null
                                  ? personnel.poste!.libelle
                                  : "Aucun"),
                          TableBodyLast(
                            items: [
                              (
                                label: Constant.detail,
                                onTap: () => onShowDetail(personnel: personnel),
                                color: null,
                              ),
                              if (personnel.etat != EtatPersonnel.archived &&
                                  hasPermission(
                                      role: role,
                                      permission: PermissionAlias
                                          .updatePersonnel.label)) ...[
                                (
                                  label: Constant.edit,
                                  onTap: () => onEdit(personnel: personnel),
                                  color: null,
                                ),
                              ],
                              if (!isCurrentUser &&
                                  hasPermission(
                                      role: role,
                                      permission: PermissionAlias
                                          .archivePersonnel.label)) ...[
                                (
                                  label:
                                      personnel.etat == EtatPersonnel.archived
                                          ? Constant.unarchived
                                          : Constant.archived,
                                  onTap: () => archivedOrDesarchivedPersonnel(
                                      personnel: personnel),
                                  color: null,
                                ),
                              ],
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  )
                : Table(
                    columnWidths: {
                      4: const FixedColumnWidth(50),
                      2: Responsive.isMobile(context)
                          ? const FixedColumnWidth(50)
                          : const FlexColumnWidth(),
                    },
                    children: widget.paginatedPersonnelData.map((personnel) {
                      bool isCurrentUser =
                          personnel.id == currentUser!.personnel!.id;
                      return TableRow(
                        decoration: tableDecoration(context),
                        children: [
                          TableBodyMiddle(valeur: personnel.nom),
                          TableBodyMiddle(valeur: personnel.prenom),
                          TableBodyMiddle(
                              valeur: personnel.poste != null
                                  ? personnel.poste != null
                                      ? personnel.poste!.libelle
                                      : "Aucun"
                                  : "Aucun"),
                          TableBodyMiddle(
                            valeur:
                                "+${personnel.pays!.code} ${personnel.telephone}",
                          ),
                          TableBodyLast(
                            items: [
                              (
                                label: Constant.detail,
                                onTap: () => onShowDetail(personnel: personnel),
                                color: null,
                              ),
                              if (personnel.etat != EtatPersonnel.archived &&
                                  hasPermission(
                                      role: role,
                                      permission: PermissionAlias
                                          .updatePersonnel.label)) ...[
                                (
                                  label: Constant.edit,
                                  onTap: () => onEdit(personnel: personnel),
                                  color: null,
                                ),
                              ],
                              if (!isCurrentUser &&
                                  hasPermission(
                                      role: role,
                                      permission: PermissionAlias
                                          .archivePersonnel.label)) ...[
                                (
                                  label:
                                      personnel.etat == EtatPersonnel.archived
                                          ? Constant.unarchived
                                          : Constant.archived,
                                  onTap: () => archivedOrDesarchivedPersonnel(
                                      personnel: personnel),
                                  color: null,
                                ),
                              ],
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}
