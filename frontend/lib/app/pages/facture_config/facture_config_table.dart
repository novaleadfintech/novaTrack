import 'package:flutter/material.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/style/app_color.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../global/constant/request_management_value.dart';
import '../../../helper/user_helper.dart';
import '../../../model/facturation/facture_global_value_model.dart';
import 'facture_value_config_page.dart';

class FactureConfigTable extends StatefulWidget {
  final List<ClientFactureGlobaLValueModel> clientFactureGlobaLValues;
  final Future<void> Function() refresh;
  const FactureConfigTable({
    super.key,
    required this.clientFactureGlobaLValues,
    required this.refresh,
  });

  @override
  State<FactureConfigTable> createState() => _InputTableState();
}

class _InputTableState extends State<FactureConfigTable> {
  late RoleModel role;
  late Future<void> _futureRoles;

  @override
  void initState() {
    _futureRoles = getRole();
    super.initState();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  // detailCategorieRubrique({required ClientFactureGlobaLValueModel clientFactureGlobaLValue}) {
  //   showDetailDialog(
  //     context,
  //     content: DetailCategorieRubriquePage(
  //       clientFactureGlobaLValue: clientFactureGlobaLValue,
  //     ),
  //     title: "Détail de moyen de paiement",
  //   );
  // }

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
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                0: const FlexColumnWidth(),
                1: const IntrinsicColumnWidth()
              },
              children: [
                ...widget.clientFactureGlobaLValues.map(
                  (clientFactureGlobaLValue) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: clientFactureGlobaLValue.client.toStringify(),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: IconButton(
                          onPressed: () {
                            if (hasPermission(
                              role: role,
                              permission: PermissionAlias
                                  .canSetFactureGlobalValues.label,
                            )) {
                              showResponsiveDialog(
                                context,
                                content: FactureValueConfigPage(
                                  clientFactureGlobaLValue:
                                      clientFactureGlobaLValue,
                                  refresh: widget.refresh,
                                ),
                                title:
                                    "facturation - ${clientFactureGlobaLValue.client.toStringify()}",
                              );
                            } else {
                              MutationRequestContextualBehavior
                                  .showCustomInformationPopUp(
                                      message:
                                          "${RequestMessage.forbidenMessage} modifier les valeurs de facturation globale.");
                            }
                          },
                          icon: Icon(
                            Icons.settings,
                            color: AppColor.primaryColor,
                          ),
                        ),
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
