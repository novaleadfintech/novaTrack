import 'package:flutter/material.dart';
import 'package:frontend/helper/string_helper.dart';
import '../../../../model/grille_salariale/classe_model.dart';
import '../../../../model/request_response.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../service/classe_service.dart';
import '../../../../widget/confirmation_dialog_box.dart';
import '../../../../global/constant/constant.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_last.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../widget/table_header.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../app_dialog_box.dart';
import '../../detail_pop.dart';
import '../../utils/grille_salariale_util.dart';
import 'detail_classe.dart';
import 'edit_classe.dart';

class ClasseTable extends StatefulWidget {
  final List<ClasseModel> classe;
  final Future<void> Function() refresh;
  const ClasseTable({
    super.key,
    required this.classe,
    required this.refresh,
  });

  @override
  State<ClasseTable> createState() => _ClasseTableState();
}

class _ClasseTableState extends State<ClasseTable> {
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
    RoleModel currentRole = await AuthService().getRole();
    setState(() {
      role = currentRole;
    });
  }

  editLibelle({
    required ClasseModel classe,
  }) {
    showResponsiveDialog(
      context,
      content: EditClasse(
          // classe: classe,
          // refresh: widget.refresh,
          ),
      title: "Modifier un classe",
    );
  }

  detailClasse({required ClasseModel classe}) {
    showDetailDialog(
      context,
      content: DetailClassePage(
        classe: classe,
      ),
      title: "Détail de classe",
    );
  }

  Future<void> deleteClasse({
    required ClasseModel classe,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer la classe de bulletin \"${classe.libelle}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await ClasseService.deleteClasse(
        key: classe.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Le classe a été supprimé avec succcès",
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
              tablesTitles: classeTableTitles,
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
                ...widget.classe.map(
                  (classe) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: capitalizeFirstLetter(word: classe.libelle),
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailClasse(classe: classe);
                            },
                            color: null, // couleur null
                          ),
                          // if (hasPermission(
                          //   role: role,
                          //   permission: PermissionAlias.updateClasse.label,
                          // ))
                          (
                            label: Constant.edit,
                            onTap: () {
                              editLibelle(classe: classe);
                            },
                            color: null,
                          ),
                          // if (hasPermission(
                          //   role: role,
                          //   permission: PermissionAlias
                          //       .deleteClasse.label,
                          // ))
                          //   (
                          //     label: Constant.delete,
                          //     onTap: () {
                          //       deleteLibelle(classe: classe);
                          //     },
                          //     color: null,
                          //   ),
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
