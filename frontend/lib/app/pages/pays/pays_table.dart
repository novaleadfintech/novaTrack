import 'package:flutter/material.dart';
import 'package:frontend/app/pages/utils/pays_util.dart';
import 'package:frontend/helper/string_helper.dart';
import 'package:frontend/model/pays_model.dart';
import '../../../global/constant/constant.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/habilitation/role_model.dart';
 import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../responsitvity/responsivity.dart';
import '../app_dialog_box.dart';
import '../detail_pop.dart';
import 'detail_pays.dart';
import 'edit_pays_page.dart';

class PaysTable extends StatefulWidget {
  final RoleModel role;
  final List<PaysModel> paginatedServiceData;

  final Future<void> Function() refresh;
  const PaysTable({
    super.key,
    required this.role,
    required this.paginatedServiceData,
    required this.refresh,
  });

  @override
  State<PaysTable> createState() => _ServiceTableState();
}

class _ServiceTableState extends State<PaysTable> {
  late RoleModel role;

  @override
  void initState() {
    role = widget.role;
    super.initState();
    // getRole();
  }

  // Future<void> getRole() async {
  //   RoleModel currentRole = await AuthService().getRole();
  //   setState(() {
  //     role = currentRole;
  //   });
  // }

  void onEdit({
    required PaysModel pays,
    required Future<void> Function() refresh,
  }) {
    showResponsiveDialog(
      context,
      title: "Modifier un pays",
      content: EditPaysPage(
        pays: pays,
        refresh: refresh,
      ),
    );
  }

  void onShowDetail({required PaysModel pays}) {
    showDetailDialog(
      context,
      content: MoreDatailPaysPage(
        pays: pays,
      ),
      title: "Détail du pays",
      widthFactor: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          columnWidths: {
            2: const FixedColumnWidth(50),
            1: Responsive.isMobile(context)
                ? const IntrinsicColumnWidth(flex: 1)
                : const FlexColumnWidth(),
            0: const FlexColumnWidth(2),
          },
          children: [
            Responsive.isMobile(context)
                ? tableHeader(tablesTitles: paysTableTitlesSmall, context)
                : tableHeader(tablesTitles: paysTableTitles, context),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                2: const FixedColumnWidth(50),
                1: Responsive.isMobile(context)
                    ? const IntrinsicColumnWidth(flex: 1)
                    : const FlexColumnWidth(),
                0: const FlexColumnWidth(2),
              },
              children: [
                ...widget.paginatedServiceData.map(
                  (pays) => Responsive.isMobile(context)
                      ? TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: capitalizeFirstLetter(word: pays.name),
                            ),
                            TableBodyMiddle(valeur: "+${pays.code}"),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    onShowDetail(pays: pays);
                                  },
                                  color: null,
                                ),
                                if (hasPermission(
                                  role: role,
                                  permission: PermissionAlias.updatePays.label,
                                ))
                                  (
                                    label: Constant.edit,
                                    onTap: () {
                                      onEdit(
                                        pays: pays,
                                        refresh: widget.refresh,
                                      );
                                    },
                                    color: null,
                                  ),
                              ],
                            )
                          ],
                        )
                      : TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: capitalizeFirstLetter(word: pays.name),
                            ),
                            TableBodyMiddle(
                              valeur: "+${pays.code}",
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    onShowDetail(pays: pays);
                                  },
                                  color: null,
                                ),
                                if (hasPermission(
                                  role: role,
                                  permission: PermissionAlias.updatePays.label,
                                ))
                                  (
                                    label: Constant.edit,
                                    onTap: () => onEdit(
                                          pays: pays,
                                          refresh: widget.refresh,
                                        ),
                                    color: null,
                                  ),
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
