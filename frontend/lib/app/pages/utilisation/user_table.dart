import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/error_page.dart';
import 'package:frontend/app/pages/utilisation/edit_user_page.dart';
import 'package:frontend/app/pages/utilisation/more_user_detail.dart';
import 'package:frontend/global/constant/constant.dart';
import 'package:frontend/model/habilitation/role_enum.dart';
import 'package:frontend/model/habilitation/user_role_model.dart';
import 'package:frontend/model/personnel/enum_personnel.dart';
import 'package:frontend/style/app_color.dart';
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
  final RoleModel role;
  final List<UserModel> paginatedUserData;
  final Future<void> Function() refresh;
  const UserTable({
    super.key,
    required this.role,
    required this.paginatedUserData,
    required this.refresh,
  });

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  late SimpleFontelicoProgressDialog _dialog;
  RoleModel? role;
  UserModel? user;

  bool _isLoading = true;
  String? _errorMessage;

  Future<void> forbide({required UserModel user}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez vous vraiment retirer l'accès à cette plateforme à ${user.personnel?.nom ?? ''} ${user.personnel?.prenom ?? ''}",
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
              "${user.personnel?.nom ?? ''} ${user.personnel?.prenom ?? ''} n'a plus désormais accès à cette plateforme",
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

  void editRole({required UserModel user}) {
    showResponsiveDialog(
      context,
      content: EditUserPage(refresh: widget.refresh, user: user),
      title: "Modifier le role d'un utilisateur",
    );
  }

  Future<void> autorise({required UserModel user}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez vous vraiment autoriser l'accès à cette plateforme à ${user.personnel?.nom ?? ''} ${user.personnel?.prenom ?? ''}",
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
              "${user.personnel?.nom ?? ''} ${user.personnel?.prenom ?? ''} a désormais accès à cette plateforme",
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

  Future<void> reinitialiserLoginParameter({required UserModel user}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez vous vraiment réinitialiser les paramètres de connexion de ${user.personnel?.nom ?? ''} ${user.personnel?.prenom ?? ''} ?",
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
              "Les paramètre de connexion de ${user.personnel?.nom ?? ''} ${user.personnel?.prenom ?? ''} ont été bien initialisés.",
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

  Future<void> assignRoleToUser({
    required UserModel user,
    required RoleModel role,
    required bool isCurrentUser,
  }) async {
    var determinant = user.personnel?.sexe == Sexe.F ? "Mme" : "M.";
    bool confirmed = await handleOperationButtonPress(context,
        content:
            "Êtes-vous sûr de vouloir definir $determinant ${user.personnel?.prenom ?? ''} ${user.personnel?.nom ?? ''} comme ${role.libelle}?");
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await UserService.assignRoleToPersonnel(
        personnelId: user.personnel!.id,
        roleId: role.id!,
        createBy: user.id!,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        try {
          MutationRequestContextualBehavior.showPopup(
              status: PopupStatus.success,
              customMessage:
                  "$determinant ${user.personnel?.prenom ?? ''} ${user.personnel?.nom ?? ''} a été defini comme ${role.libelle}");
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

  Future<void> handelRoleAutorization({
    required UserModel use,
  }) async {
    try {
      UserRoleModel userRole = getRoleSwitchAutorization(
          roles: use.roles!, roleAuthorization: RoleAuthorization.wait)!;
      var demandedeterminant =
          userRole.createBy?.personnel?.sexe == Sexe.F ? "Mme" : "M.";

      var ownnerdeterminant = use.personnel?.sexe == Sexe.F ? "Mme" : "M.";
      bool confirmed = await handleOperationButtonPress(context,
          content:
              "$demandedeterminant ${userRole.createBy?.personnel?.toStringify() ?? ''} souhaite définir $ownnerdeterminant ${use.personnel?.toStringify() ?? ''} comme ${role?.libelle}.\nAcceptez-vous?");
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await UserService.handleRoleEditing(
        userRoleId: userRole.id,
        roleAuthorization:
            confirmed ? RoleAuthorization.accepted : RoleAuthorization.refused,
        authorizer: user!.id!,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
            status: PopupStatus.success, customMessage: "Enrégistré avec succès"
            // "$ownnerdeterminant ${user.personnel?.prenom ?? ''} ${user.personnel?.nom ?? ''} a été defini comme ${role.libelle}"
            );

        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    } catch (err) {
       

      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.serverError,
        customMessage: err.toString(),
      );
    }
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final results = await Future.wait([
        AuthService().getRole(),
        AuthService().decodeToken(),
      ]);

      setState(() {
        role = results[0] as RoleModel;
        user = results[1] as UserModel?;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ErrorPage(
        message: _errorMessage!,
        onPressed: () async {
          await _initializeData();
          await widget.refresh();
        },
      );
    }

    if (role == null) {
      return const Center(
          child: Text('Impossible de charger les données du rôle.'));
    }

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
                  bool isCurrentUser = use.id == user?.id;
                  return Responsive.isMobile(context)
                      ? TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur:
                                  '${use.personnel?.nom ?? ''} ${use.personnel?.prenom ?? ''}',
                            ),
                            TableBodyMiddle(
                                valeur: capitalizeFirstLetter(
                              word: (use.roles != null &&
                                      use.roles!.isNotEmpty &&
                                      verifyRoleAuthorization(
                                          roles: use.roles!,
                                          roleAuthorization:
                                              RoleAuthorization.accepted))
                                  ? (getRoleSwitchAutorization(
                                          roles: use.roles!,
                                          roleAuthorization:
                                              RoleAuthorization.accepted))!
                                      .role
                                      .libelle
                                  : "Aucun rôle",
                            )),
                            Stack(
                              children: [
                                TableBodyLast(
                                  items: [
                                    if ((use.canLogin ?? false) &&
                                        !isCurrentUser &&
                                        use.personnel?.etat !=
                                            EtatPersonnel.archived &&
                                        role != null &&
                                        hasPermission(
                                          role: role!,
                                          permission: PermissionAlias
                                              .assignRolePersonnel.label,
                                        ) &&
                                        verifyRoleAuthorization(
                                            roleAuthorization:
                                                RoleAuthorization.accepted,
                                            roles: use.roles!)) ...[
                                      (
                                        label: Constant.reinitialiser,
                                        onTap: () {
                                          reinitialiserLoginParameter(
                                              user: use);
                                        },
                                        color: null,
                                      ),
                                      (
                                        label: Constant.edit,
                                        onTap: () {
                                          editRole(user: use);
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
                                    if (!(use.canLogin ?? false) &&
                                        use.roles != null &&
                                        use.roles!.isNotEmpty &&
                                        hasAcceptedRoleWithPermission(
                                          roles: use.roles!,
                                          permission: PermissionAlias
                                              .assignRolePersonnel.label,
                                        )) ...[
                                      (
                                        label: Constant.autorise,
                                        onTap: () {
                                          autorise(user: use);
                                        },
                                        color: null,
                                      ),
                                    ],
                                    if ((use.canLogin ?? false) &&
                                        use.personnel?.etat ==
                                            EtatPersonnel.unarchived &&
                                        use.roles != null &&
                                        use.roles!.isNotEmpty &&
                                        verifyRoleAuthorization(
                                          roles: use.roles!,
                                          roleAuthorization:
                                              RoleAuthorization.wait,
                                        ) &&
                                        hasPermission(
                                          role: role!,
                                          permission: PermissionAlias
                                              .handelRoleAutorization.label,
                                        )) ...[
                                      (
                                        label: Constant.verifyRoleAuthorization,
                                        onTap: () async {
                                          await handelRoleAutorization(
                                            use: use,
                                          );
                                        },
                                        color: AppColor.modificationColor,
                                      ),
                                    ],
                                    (
                                      label: Constant.detail,
                                      onTap: () {
                                        detail(user: use);
                                      },
                                      color: null,
                                    ),
                                  ],
                                ),
                                if (!(use.canLogin!) ||
                                    use.personnel?.etat ==
                                        EtatPersonnel.archived)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Icon(Icons.lock,
                                        size: 16, color: AppColor.redColor),
                                  ),
                                if ((use.canLogin ?? false) &&
                                    use.personnel?.etat ==
                                        EtatPersonnel.unarchived &&
                                    use.roles != null &&
                                    use.roles!.isNotEmpty &&
                                    verifyRoleAuthorization(
                                        roles: use.roles!,
                                        roleAuthorization:
                                            RoleAuthorization.wait))
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Icon(Icons.priority_high,
                                        color: AppColor.redColor),
                                  ),
                              ],
                            )
                          ],
                        )
                      : TableRow(
                          decoration: !(use.canLogin ?? false) ||
                                  use.personnel?.etat == EtatPersonnel.archived
                              ? inactiveUsertableDecoration(context)
                              : tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: use.personnel?.nom ?? '',
                            ),
                            TableBodyMiddle(
                              valeur: use.personnel?.prenom ?? '',
                            ),
                            TableBodyMiddle(
                                valeur: capitalizeFirstLetter(
                              word: (use.roles != null && use.roles!.isNotEmpty)
                                  ? use.roles!
                                          .where((userRole) =>
                                              userRole.roleAuthorization ==
                                              RoleAuthorization.accepted)
                                          .isNotEmpty
                                      ? use.roles!
                                          .lastWhere((userRole) =>
                                              userRole.roleAuthorization ==
                                              RoleAuthorization.accepted)
                                          .role
                                          .libelle
                                      : "Aucun rôle"
                                  : "Aucun rôle",
                            )),
                            Stack(
                              children: [
                                TableBodyLast(
                                  items: [
                                    if ((use.canLogin ?? false) &&
                                        !isCurrentUser &&
                                        use.personnel?.etat !=
                                            EtatPersonnel.archived &&
                                        role != null &&
                                        hasPermission(
                                          role: role!,
                                          permission: PermissionAlias
                                              .assignRolePersonnel.label,
                                        ) &&
                                        verifyRoleAuthorization(
                                            roleAuthorization:
                                                RoleAuthorization.accepted,
                                            roles: use.roles!)) ...[
                                      (
                                        label: Constant.reinitialiser,
                                        onTap: () {
                                          reinitialiserLoginParameter(
                                              user: use);
                                        },
                                        color: null,
                                      ),
                                      (
                                        label: Constant.edit,
                                        onTap: () {
                                          editRole(user: use);
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
                                    if (!(use.canLogin ?? false) &&
                                        use.roles != null &&
                                        use.roles!.isNotEmpty &&
                                        hasAcceptedRoleWithPermission(
                                          roles: use.roles!,
                                          permission: PermissionAlias
                                              .assignRolePersonnel.label,
                                        )) ...[
                                      (
                                        label: Constant.autorise,
                                        onTap: () {
                                          autorise(user: use);
                                        },
                                        color: null,
                                      ),
                                    ],
                                    if ((use.canLogin ?? false) &&
                                        use.personnel?.etat ==
                                            EtatPersonnel.unarchived &&
                                        use.roles != null &&
                                        use.roles!.isNotEmpty &&
                                        verifyRoleAuthorization(
                                            roles: use.roles!,
                                            roleAuthorization:
                                                RoleAuthorization.wait) &&
                                        hasPermission(
                                            role: widget.role,
                                            permission: PermissionAlias
                                                .handelRoleAutorization
                                                .label)) ...[
                                      (
                                        label: Constant.verifyRoleAuthorization,
                                        onTap: () async {
                                          await handelRoleAutorization(
                                            use: use,
                                          );
                                        },
                                        color: AppColor.modificationColor,
                                      ),
                                    ],
                                    (
                                      label: Constant.detail,
                                      onTap: () {
                                        detail(user: use);
                                      },
                                      color: null,
                                    ),
                                  ],
                                ),
                                if (!(use.canLogin!) ||
                                    use.personnel?.etat ==
                                        EtatPersonnel.archived)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Icon(Icons.lock,
                                        size: 16, color: AppColor.redColor),
                                  ),
                                if ((use.canLogin ?? false) &&
                                    use.personnel?.etat ==
                                        EtatPersonnel.unarchived &&
                                    use.roles != null &&
                                    use.roles!.isNotEmpty &&
                                    verifyRoleAuthorization(
                                        roles: use.roles!,
                                        roleAuthorization:
                                            RoleAuthorization.wait))
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Icon(Icons.priority_high,
                                        color: AppColor.redColor),
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
