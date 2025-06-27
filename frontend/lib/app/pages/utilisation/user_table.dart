import 'package:flutter/material.dart';
import 'package:frontend/app/pages/error_page.dart';
import 'package:frontend/app/pages/utilisation/more_user_detail.dart';
import 'package:frontend/global/constant/constant.dart';
import 'package:frontend/model/personnel/enum_personnel.dart';
import '../../../auth/authentification_token.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/string_helper.dart';
import '../../../helper/user_helper.dart';
import '../../../model/request_response.dart';
import '../../responsitvity/responsivity.dart';
import '../../../model/common_type.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../service/user_service.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../widget/confirmation_dialog_box.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../detail_pop.dart';
import '../utils/user_util.dart';

class UserTable extends StatefulWidget {
  final List<UserModel> paginatedUserData;
  final Future<void> Function() refresh;
  const UserTable({
    super.key,
    required this.paginatedUserData,
    required this.refresh,
  });

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  late SimpleFontelicoProgressDialog _dialog;
  List<RoleModel> roles = [];
  late UserModel? user;

  late Future<UserModel?> _futureRoles;
  
  forbide({required UserModel user}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez vous vraiment retirer l'accès à cette plateforme à ${user.personnel!.nom} ${user.personnel!.prenom}",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );
      RequestResponse result =
          await UserService.access(userId: user.id!, canLogin: false);
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage:
              "${user.personnel!.nom} ${user.personnel!.prenom} n'a plus désormais accès à cette plateforme",
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

  autorise({required UserModel user}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez vous vraiment autoriser l'accès à cette plateforme à ${user.personnel!.nom} ${user.personnel!.prenom}",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );
      RequestResponse result =
          await UserService.access(userId: user.id!, canLogin: true);
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage:
              "${user.personnel!.nom} ${user.personnel!.prenom} a désormais accès à cette plateforme",
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

  reinitialiserLoginParameter({required UserModel user}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez vous vraiment réinitialiser les paramètres de connexion de ${user.personnel!.nom} ${user.personnel!.prenom}",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );
      RequestResponse result =
          await UserService.resetLoginParameter(userId: user.id!);
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage:
              "Les paramètre de connexion de ${user.personnel!.nom} ${user.personnel!.prenom} ont été bien initialisés.",
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

  assignRoleToUser({
    required UserModel user,
    required RoleModel role,
  }) async {
    var determinant = user.personnel!.sexe == Sexe.F ? "Mme" : "M.";
    bool confirmed = await handleOperationButtonPress(context,
        content:
            "Êtes-vous sûr de vouloir definir $determinant ${user.personnel!.prenom} ${user.personnel!.nom} comme ${role.libelle}?");
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await UserService.assignRoleToPersonnel(
        personnelId: user.personnel!.id,
        roleId: role.id!,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        try {
          MutationRequestContextualBehavior.showPopup(
              status: PopupStatus.success,
              customMessage:
                  "$determinant ${user.personnel!.prenom} ${user.personnel!.nom} a été defini comme ${role.libelle}");
        } catch (err) {
          MutationRequestContextualBehavior.showPopup(
            status: PopupStatus.serverError,
            customMessage: "",
          );
        }
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    }
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
  }
Future<UserModel?> getcurrentUser() async {
    return await AuthService().decodeToken();
  }

  

  @override
void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _futureRoles = getcurrentUser();
    getRoles();
    super.initState();
  }


  @override
Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _futureRoles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return ErrorPage(
            message: "Erreur lors de la récupération de l'utilisateur",
            onPressed: () {},
          );
        } else if (snapshot.data != null) {
          user = snapshot.data!; 
          return Column(
            children: [
              Table(
                columnWidths: {
                  2: Responsive.isMobile(context)
                      ? const FixedColumnWidth(50)
                      : const FlexColumnWidth(),
                  3: const FixedColumnWidth(50),
                },
                children: [
                  Responsive.isMobile(context)
                      ? tableHeader(
                          tablesTitles: userTableTitlesSmall,
                          context,
                        )
                      : tableHeader(
                          tablesTitles: userTableTitles,
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
                      3: const FixedColumnWidth(50),
                    },
                    children: widget.paginatedUserData.map(
                      (use) {
                        bool isCurrentUser = use.id == user!.id;
                        return Responsive.isMobile(context)
                            ? TableRow(
                                decoration: !use.canLogin! ||
                                        use.personnel!.etat ==
                                            EtatPersonnel.archived
                                    ? inactiveUsertableDecoration(context)
                                    : tableDecoration(context),
                                children: [
                                  TableBodyMiddle(
                                    valeur:
                                        '${use.personnel!.nom} ${use.personnel!.prenom}',
                                  ),
                                  TableBodyMiddle(
                                      valeur: capitalizeFirstLetter(
                                    word: (use.roles != null &&
                                            use.roles!.isNotEmpty)
                                        ? use.roles!.first.libelle
                                        : "Aucun rôle",
                                  )),
                                  TableBodyLast(
                                    items: [
                                      if (use.canLogin! &&
                                          !isCurrentUser &&
                                          use.personnel!.etat !=
                                              EtatPersonnel.archived &&
                                          hasPermission(
                                            roles: roles,
                                            permission: PermissionAlias
                                                .assignRolePersonnel.label,
                                          )) ...[
                                        (
                                          label: Constant.reinitialiser,
                                          onTap: () {
                                            reinitialiserLoginParameter(
                                                user: use);
                                          },
                                          color: null, 
                                        ),
                                        (
                                          label: Constant.forbide,
                                          onTap: () {
                                            forbide(user: use);
                                          },
                                          color: null, 
                                        ),
                                      ],
                                      if (!use.canLogin! &&
                                          hasPermission(
                                            roles: user!.roles!,
                                            permission: PermissionAlias
                                                .assignRolePersonnel.label,
                                          )) ...[
                                        (
                                          label: Constant.autorise,
                                          onTap: () {
                                            autorise(user: use);
                                          },
                                          color: null, // couleur null
                                        ),
                                      ],
                                      (
                                        label: Constant.detail,
                                        onTap: () {
                                          detail(user: use);
                                        },
                                        color: null, // couleur null
                                      ),
                                    ],
                                  )

                                ],
                              )
                            : TableRow(
                                decoration: !use.canLogin! ||
                                        use.personnel!.etat ==
                                            EtatPersonnel.archived
                                    ? inactiveUsertableDecoration(context)
                                    : tableDecoration(context),
                                children: [
                                  TableBodyMiddle(
                                    valeur: use.personnel!.nom,
                                  ),
                                  TableBodyMiddle(
                                    valeur: use.personnel!.prenom,
                                  ),
                                  TableBodyMiddle(
                                      valeur: capitalizeFirstLetter(
                                    word: (use.roles != null &&
                                            use.roles!.isNotEmpty)
                                        ? use.roles!.first.libelle
                                        : "Aucun rôle",
                                  )),
                                  TableBodyLast(
                                    items: [
                                      if (use.canLogin! &&
                                          !isCurrentUser &&
                                          use.personnel!.etat !=
                                              EtatPersonnel.archived &&
                                          hasPermission(
                                            roles: roles,
                                            permission: PermissionAlias
                                                .assignRolePersonnel.label,
                                          )) ...[
                                        (
                                          label: Constant.reinitialiser,
                                          onTap: () {
                                            reinitialiserLoginParameter(
                                                user: use);
                                          },
                                          color: null, // couleur null
                                        ),
                                        (
                                          label: Constant.forbide,
                                          onTap: () {
                                            forbide(user: use);
                                          },
                                          color: null, // couleur null
                                        ),
                                      ],
                                      if (!use.canLogin! &&
                                          hasPermission(
                                            roles: user!.roles!,
                                            permission: PermissionAlias
                                                .assignRolePersonnel.label,
                                          )) ...[
                                        (
                                          label: Constant.autorise,
                                          onTap: () {
                                            autorise(user: use);
                                          },
                                          color: null, // couleur null
                                        ),
                                      ],
                                      (
                                        label: Constant.detail,
                                        onTap: () {
                                          detail(user: use);
                                        },
                                        color: null, // couleur null
                                      ),
                                    ],
                                  )

                                ],
                              );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('Aucune donnée disponible.'));
      },
    );
  }

  void detail({required UserModel user}) {
    showDetailDialog(
      context,
      content: MoreUserDetail(
      user: user,
      ),
      title: "Detail de l'utilisateur",
    );
  }

}
