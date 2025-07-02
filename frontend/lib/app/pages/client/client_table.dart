import 'package:flutter/material.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/user_helper.dart';
import '../app_dialog_box.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
 
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../global/constant/constant.dart';
import '../../../model/client/client_model.dart';
import '../../../model/client/enum_client.dart';
import '../../../service/client_service.dart';
import '../../../style/app_style.dart';
import '../../../widget/confirmation_dialog_box.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_left.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../responsitvity/responsivity.dart';
import '../utils/client_util.dart';
import 'edit_client_page.dart';

class ClientTable extends StatefulWidget {
  final List<ClientModel> paginatedClientData;
  final Function(ClientModel) onDetailClients;
  final Future<void> Function() refresh;
  const ClientTable({
    super.key,
    required this.paginatedClientData,
    required this.onDetailClients,
    required this.refresh,
  });

  @override
  State<ClientTable> createState() => _ClientTableState();
}

class _ClientTableState extends State<ClientTable> {
  late SimpleFontelicoProgressDialog _dialog;
  late RoleModel role;
  late Future<void> _futureRoles;
  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _futureRoles = getRole();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  onEdit({
    required ClientModel client,
  }) {
    showResponsiveDialog(
      context,
      title: "Modifier un partenaire",
      content: EditClientPage(
        client: client,
        refresh: widget.refresh,
      ),
    );
  }

  onShowDetail({
    required ClientModel client,
  }) {
    widget.onDetailClients(client);
  }

  archivedorDesarchivedClient({
    required ClientModel client,
  }) async {
    bool isArchived = client.etat == EtatClient.archived;
    bool confirmed = await handleOperationButtonPress(
      context,
      content: isArchived
          ? "Voulez vous vraiment désarchiver le partenaire ${client.toStringify()}??"
          : "Voulez-vous vraiment archiver le partenaire ${client.toStringify()}?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );
     
      var result = client.etat == EtatClient.unarchived
          ? await ClientService.archiveClient(
              clientId: client.id,
            )
          : await ClientService.unarchiveClient(
              clientId: client.id,
            );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: isArchived
              ? "Le partenaire a été désarchivé avec succcès"
              : "Le partenaire a été archivé avec succcès",
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
    return FutureBuilder(
      future: _futureRoles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur de chargement des rôles'));
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
            4: const FixedColumnWidth(50),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(50)
                : const FlexColumnWidth(),
            1: Responsive.isMobile(context)
                ? const FixedColumnWidth(150)
                : const FlexColumnWidth(),
            3: FixedColumnWidth(100),

            0: const FlexColumnWidth(),
          },
          children: [
            Responsive.isMobile(context)
                ? tableHeader(
                    tablesTitles: clientsTableTitlesSmall,
                    context,
                  )
                : tableHeader(
                    tablesTitles: clientsTableTitles,
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
                3: FixedColumnWidth(100),
                1: Responsive.isMobile(context)
                    ? const FixedColumnWidth(150)
                    : const FlexColumnWidth(),
                0: const FlexColumnWidth(),
              },
              children: [
                ...widget.paginatedClientData.map(
                  (client) => TableRow(
                    decoration: tableDecoration(context),
                    children: Responsive.isMobile(context)
                        ? [
                            TableBodyFirst(client: client),
                            TableBodyMiddle(
                              valeur:
                                  "+${client.pays!.code} ${client.telephone.toString()}",
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    onShowDetail(client: client);
                                  },
                                  color: null,
                                ),
                                if (hasPermission(
                                    role: role,
                                    permission:
                                        PermissionAlias.archiveClient.label))
                                        (
                                          label:
                                              client.etat == EtatClient.archived
                                                  ? Constant.unarchived
                                                  : Constant.archived,
                                          onTap: () {
                                            archivedorDesarchivedClient(
                                                client: client);
                                          },
                                          color: null, // couleur null
                                        ),
                                if (hasPermission(
                                        role: role,
                                        permission: PermissionAlias
                                            .updateClient.label) &&
                                    client.etat == EtatClient.unarchived)
                                  (
                                    label: Constant.edit,
                                    onTap: () {
                                      onEdit(client: client);
                                    },
                                    color: null,
                                  ),
                                  
                                     
                              ],
                            )

                          ]
                        : [
                            TableBodyFirst(client: client),
                            TableBodyMiddle(valeur: client.pays!.name),
                            TableBodyMiddle(valeur: client.email),
                            TableBodyMiddle(valeur: client.nature!.label),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    onShowDetail(client: client);
                                  },
                                  color: null,
                                ),
                                if (hasPermission(
                                    role: role,
                                    permission:
                                        PermissionAlias.archiveClient.label))
                                        (
                                          label:
                                              client.etat == EtatClient.archived
                                                  ? Constant.unarchived
                                                  : Constant.archived,
                                          onTap: () {
                                            archivedorDesarchivedClient(
                                                client: client);
                                          },
                                    color: null, 
                                        ),
                                if (hasPermission(
                                        role: role,
                                        permission: PermissionAlias
                                            .updateClient.label) &&
                                    client.etat == EtatClient.unarchived)
                                        (
                                          label: Constant.edit,
                                          onTap: () {
                                            onEdit(client: client);
                                          },
                                    color: null, 
                                        ),
                                   
                              ],
                            )

                          ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
