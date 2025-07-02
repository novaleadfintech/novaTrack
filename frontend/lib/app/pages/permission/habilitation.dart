import 'package:flutter/material.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/app/pages/no_data_page.dart';
import 'package:frontend/model/habilitation/module_permission_model.dart';
import 'package:frontend/model/habilitation/role_model.dart';
import 'package:frontend/service/module_permission.dart';
import 'package:frontend/style/app_style.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/habilitation/permission_model.dart';
import '../../../service/role_service.dart';
import '../../../style/app_color.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../integration/popop_status.dart';

import '../../../widget/table_body_middle.dart';
import 'package:gap/gap.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  RoleModel? profil;
  List<ModulePermissionModel> permissions = [];
  bool isLoading = false;
  String? errMessage;
  late SimpleFontelicoProgressDialog _dialog;
  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  // onClickAddProfilButton() {
  //   showCustomPoppup(
  //     context,
  //     content: const AddProfil(),
  //     title: "Nouveau profil",
  //   );
  // }

  Future<List<RoleModel>> fetchRoleItems() async {
    return await RoleService.getRole();
  }

  Future<void> fetchPermissionsByRole({required RoleModel profil}) async {
    setState(() => isLoading = true);
    try {
      permissions =
          await ModulePermissionService.getModuleParmission(
        id: profil.id!,
      );
      setState(() {});
    } catch (e) {
      setState(() {
        {
          errMessage = e.toString();
        }
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // En-tête avec sélection de profil et bouton d'ajout - FIXE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: FutureCustomDropDownField<RoleModel>(
                    label: "Veuillez selectionner un rôle",
                    showSearchBox: false,
                    selectedItem: profil,
                    required: false,
                    fetchItems: fetchRoleItems,
                    onChanged: (RoleModel? value) async {
                      if (value != null) {
                        if (value != profil) {
                          setState(() => profil = value);
                          await fetchPermissionsByRole(profil: profil!);
                        }
                      }
                    },
                    canClose: false,
                    itemsAsString: (s) => s.libelle,
                  ),
                ),
              ],
            ),
            const Gap(8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errMessage != null
                      ? Center(child: Text(errMessage!))
                      : permissions.isEmpty && profil != null
                          ? const NoDataPage(
                              data: [],
                              message: "Aucune permission trouvée",
                            )
                          : profil == null
                              ? const NoDataPage(
                                  data: [],
                                  message:
                                      "Cliquez dans le champs en haut pour selectionner un profil afin de le configuer",
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    children: permissions.map((moduleper) {
                                      ModulePermissionModel modulePermission =
                                          moduleper;
                                      return Container(
                                        margin: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColor.popGrey,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Text(
                                                    modulePermission
                                                        .module.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                modulePermission
                                                        .permissions.isNotEmpty
                                                    ? Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Table(
                                                              border: TableBorder
                                                                  .all(
                                                                      width:
                                                                          0.2),
                                                              columnWidths: const {
                                                                1: IntrinsicColumnWidth()
                                                              },
                                                              children:
                                                                  modulePermission
                                                                      .permissions
                                                                      .map(
                                                                        (permission) =>
                                                                            TableRow(
                                                                          decoration: permission!.isChecked!
                                                                              ? checkPermissionTableDecoration(context)
                                                                              : checkNotPermissionTableDecoration(context),
                                                                          children: [
                                                                            TableBodyMiddle(
                                                                              valeur: permission.libelle,
                                                                            ),
                                                                            TableCell(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                                                child: Checkbox(
                                                                                    value: permission.isChecked,
                                                                                    onChanged: (value) {
                                                                                      if (value != null) {
                                                                                        setState(() {
                                                                                          // Trouver l'index de l'élément dans la liste
                                                                                          int index = modulePermission.permissions.indexWhere((p) => p!.id == permission.id);

                                                                                          if (index != -1) {
                                                                                            // Remplacer l'objet par une nouvelle instance modifiée
                                                                                            modulePermission.permissions[index] = PermissionModel(
                                                                                              id: permission.id,
                                                                                              libelle: permission.libelle,
                                                                                              alias: permission.alias,
                                                                                              isChecked: value, // Nouvelle valeur
                                                                                            );
                                                                                          }
                                                                                        });
                                                                                      }
                                                                                    }),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                      .toList(),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              child: IconButton(
                                                                icon: Icon(
                                                                  Icons.save,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                                ),
                                                                onPressed: () =>
                                                                    validateModulePermissions(
                                                                  modulePermission,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Center(
                                                        child: Text(
                                                          "Aucune permission",
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
            ),
          ],
        ),
      ),
    );
  }

  void validateModulePermissions(ModulePermissionModel modulePermission) async {
    if (profil == null) return;

    try {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );
      for (var permission in modulePermission.permissions) {
        if (permission == null) continue;

        if (permission.isChecked!) {
          // Ajouter la permission
          await RoleService.attribuerPermissionRole(
            rolekey: profil!.id!,
            permissionId: permission.id,
          );
        } else {
          // Retirer la permission
          await RoleService.retirerPermissionRole(
            rolekey: profil!.id!,
            permissionId: permission.id,
          );
        }
      }
      _dialog.hide();

      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage:
            "Permissions du module ${modulePermission.module.name.toLowerCase()} mises à jour !",
      );
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage:
            "Une erreur s'est produite lors de la mise à jour des permissions${e.toString()}",
      );
    } 
  }
}
