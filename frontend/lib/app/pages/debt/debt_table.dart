import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/debt/pay_debt.dart';
import '../../../model/flux_financier/debt_model.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../detail_pop.dart';
import '../../../global/constant/constant.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../responsitvity/responsivity.dart';
import '../utils/debt_util.dart';
import 'detail_debt.dart';

class DebtTable extends StatefulWidget {
  final RoleModel role;

  final List<DebtModel> debts;
  final Future<void> Function() refresh;
  const DebtTable({
    super.key,
    required this.role,
    required this.debts,
    required this.refresh,
  });

  @override
  State<DebtTable> createState() => _DebtTableState();
}

class _DebtTableState extends State<DebtTable> {
  UserModel? user;
  late RoleModel role;

  Future<void> getCurrentUser() async {
    UserModel? currentUser = await AuthService().decodeToken();
    setState(() {
      user = currentUser;
    });
  }

  // editDebt({required DebtModel debt}) {
  //   showResponsiveDialog(
  //     context,
  //     content: EditDebtFiancierPage(
  //       debt: debt,
  //       refresh: widget.refresh,
  //     ),
  //     title: "Modifier un debt financier",
  //   );
  // }

  _payer({required DebtModel debt}) async {
    showResponsiveDialog(
      context,
      content: PayDebt(
        refresh: widget.refresh,
      ),
      title: 'Payer la dette',
    );
  }

  detailDebt({required DebtModel debt}) {
    showDetailDialog(
      context,
      content: DetailDebtPage(
        debt: debt,
      ),
      title: "Détail de debt financier",
    );
  }

  @override
  void initState() {
    getCurrentUser();
    role = widget.role;
    // getRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        Table(
          columnWidths: {
            3: const FixedColumnWidth(50),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(50)
                : const FlexColumnWidth(),
            0: const FlexColumnWidth(2)
          },
          children: [
            Responsive.isMobile(context)
                ? tableHeader(
                    tablesTitles: debtTableTitlesSmall,
                    context,
                  )
                : tableHeader(
                    tablesTitles: debtTableTitles,
                    context,
                  ),
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

                0: const FlexColumnWidth(2)
              },
              children: [
                ...widget.debts.map(
                  (debt) => Responsive.isMobile(context)
                      ? TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: debt.libelle!,
                            ),
                            TableBodyMiddle(
                              valeur:
                                  Formatter.formatAmount(debt.montant),
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    detailDebt(debt: debt);
                                  },
                                  color: null,
                                ),
                                (
                                  label: Constant.payer,
                                  onTap: () {
                                    _payer(debt: debt);
                                  },
                                  color: null,
                                ),
                              ],
                            ),
                          ],
                        )
                      : TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: debt.libelle!,
                            ),
                            
                            TableBodyMiddle(
                              valeur: Formatter.formatAmount(debt.montant),
                            ),
                            TableBodyMiddle(
                              valeur: getStringDate(
                                time: debt.dateOperation!,
                              ),
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    detailDebt(debt: debt);
                                  },
                                  color: null,
                                ),
                                (
                                  label: Constant.payer,
                                  onTap: () {
                                    _payer(debt: debt);
                                  },
                                  color: null,
                                ),
                              ],
                            ),
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
