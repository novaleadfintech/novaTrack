import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/debt/pay_debt.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../detail_pop.dart';
import '../../../global/constant/constant.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../responsitvity/responsivity.dart';
import '../flux_financier/detail_flux.dart';
import '../utils/flux_util.dart';

class DebtTable extends StatefulWidget {
  final RoleModel role;

  final List<FluxFinancierModel> fluxFinanciers;
  final Future<void> Function() refresh;
  const DebtTable({
    super.key,
    required this.role,
    required this.fluxFinanciers,
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

  // editFlux({required FluxFinancierModel flux}) {
  //   showResponsiveDialog(
  //     context,
  //     content: EditFluxFiancierPage(
  //       flux: flux,
  //       refresh: widget.refresh,
  //     ),
  //     title: "Modifier un flux financier",
  //   );
  // }

  _payer({required FluxFinancierModel flux}) async {
    showResponsiveDialog(
      context,
      content: PayDebt(
        flux: flux,
        refresh: widget.refresh,
      ),
      title: 'Payer la dette',
    );
  }

  detailFlux({required FluxFinancierModel flux}) {
    showDetailDialog(
      context,
      content: DetailFluxPage(
        flux: flux,
      ),
      title: "Détail de flux financier",
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
            4: const FixedColumnWidth(50),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(50)
                : const FlexColumnWidth(),
            3: const FixedColumnWidth(180),
            0: const FlexColumnWidth(2)
          },
          children: [
            Responsive.isMobile(context)
                ? tableHeader(
                    tablesTitles: fluxTableTitlesSmall,
                    context,
                  )
                : tableHeader(
                    tablesTitles: fluxTableTitles,
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
                3: const FixedColumnWidth(180),
                0: const FlexColumnWidth(2)
              },
              children: [
                ...widget.fluxFinanciers.map(
                  (fluxFinancier) => Responsive.isMobile(context)
                      ? TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: fluxFinancier.libelle!,
                            ),
                            TableBodyMiddle(
                              valeur:
                                  Formatter.formatAmount(fluxFinancier.montant),
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    detailFlux(flux: fluxFinancier);
                                  },
                                  color: null,
                                ),
                                (
                                  label: Constant.payer,
                                  onTap: () {
                                    _payer(flux: fluxFinancier);
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
                              valeur: fluxFinancier.libelle!,
                            ),
                            
                            TableBodyMiddle(
                              valeur: fluxFinancier.moyenPayement!.libelle,
                            ),
                            TableBodyMiddle(
                              valeur: getStringDate(
                                time: fluxFinancier.dateOperation!,
                              ),
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    detailFlux(flux: fluxFinancier);
                                  },
                                  color: null,
                                ),
                                (
                                  label: Constant.payer,
                                  onTap: () {
                                    _payer(flux: fluxFinancier);
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
