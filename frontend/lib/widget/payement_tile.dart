import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/model/flux_financier/type_flux_financier.dart';
import '../app/pages/app_dialog_box.dart';
import '../app/pages/detail_pop.dart';
import '../app/pages/flux_financier/detail_flux.dart';
import '../app/pages/payement/add_payement.dart';
import '../app/pages/payement/edit_payement.dart';
import '../app/pages/utils/payement_util.dart';
import '../app/responsitvity/responsivity.dart';
import '../auth/authentification_token.dart';
import '../global/constant/constant.dart';
import '../global/constant/permission_alias.dart';
import '../helper/amout_formatter.dart';
import '../helper/assets/asset_icon.dart';
import '../helper/date_helper.dart';
import '../helper/user_helper.dart';
import '../model/facturation/facture_model.dart';
import '../model/flux_financier/flux_financier_model.dart';
import '../model/habilitation/role_model.dart';
import '../model/habilitation/user_model.dart';
import 'app_accordion.dart';
import 'subtile_header.dart';
import 'table_body_last.dart';
import 'table_body_middle.dart';

class PayementTile extends StatelessWidget {
  final FactureModel facture;
  final Future<void> Function() refresh;
  const PayementTile({
    super.key,
    required this.refresh,
    required this.facture,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return AppAccordion(
      header: isMobile
          ? Table(
              children: [
                TableRow(
                  children: [
                    TableBodyMiddle(
                      valeur: facture.reference,
                    ),
                    TableBodyMiddle(
                      valeur: facture.client!.toStringify(),
                    ),
                  ],
                ),
              ],
            )
          : Table(
              columnWidths: const {
                3: FixedColumnWidth(150),
              },
              children: [
                TableRow(
                  children: [
                    TableBodyMiddle(
                      valeur: facture.reference,
                    ),
                    TableBodyMiddle(
                      valeur: facture.client!.toStringify(),
                    ),
                    TableBodyMiddle(
                        valeur: getStringDate(
                            time: facture.dateEtablissementFacture!)),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(facture.montant!),
                    ),
                  ],
                ),
              ],
            ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PayementDetail(
            facture: facture,
            refresh: refresh,
          ),
        ],
      ),
    );
  }
}

class PayementDetail extends StatefulWidget {
  final FactureModel facture;
  final Future<void> Function() refresh;
  const PayementDetail({
    super.key,
    required this.refresh,
    required this.facture,
  });

  @override
  State<PayementDetail> createState() => _PayementDetailState();
}

class _PayementDetailState extends State<PayementDetail> {
  UserModel? user;
  List<RoleModel> roles = [];

  Future<void> getCurrentUser() async {
    UserModel? currentUser = await AuthService().decodeToken();
    setState(() {
      user = currentUser;
    });
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
  }

  addPayement({required FactureModel facture}) {
    if (facture.payements!.length > facture.facturesAcompte.length) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message:
            "Vous ne pouvez pas enregistrement de cette facture. Quelque chose n'est pas normal.",
      );
      return;
    }
    if (facture.payements!.isNotEmpty &&
        (facture.payements![facture.payements!.length - 1].status !=
            FluxFinancierStatus.valid)) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message:
            "Le précédent encaissement de cette facture n'a pas encore été validé.\nVeuillez contacter une personne habilitée à le valider avant d'effectuer un nouveau encaissement.",
      );
      return;
    }
    showResponsiveDialog(
      context,
      content: AddPayement(
        facture: facture,
        refresh: widget.refresh,
      ),
      title: "Nouveau encaissement",
    );
  }

  editPayement({required FluxFinancierModel payement}) {
    showResponsiveDialog(
      context,
      content: EditPayement(
        payement: payement,
        refresh: widget.refresh,
      ),
      title: "Modifier une encaissement",
    );
  }

  detailPayement({required FluxFinancierModel payement}) {
    showDetailDialog(
      context,
      content: DetailFluxPage(
        flux: payement,
      ),
      title: "Detail d'encaissement",
    );
  }

  @override
  void initState() {
    getCurrentUser();
    getRoles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    // final isTablet = Responsive.isTablet(context);
    return Table(
      columnWidths: {
        4: const IntrinsicColumnWidth(),
        3: const IntrinsicColumnWidth(),
        2: isMobile ? const IntrinsicColumnWidth() : const FlexColumnWidth(),
        1: isMobile ? const IntrinsicColumnWidth() : const FlexColumnWidth(),
        0: const FlexColumnWidth(2),
      },
      children: [
        subTableHeader(
          context,
          tablesTitles:
              isMobile ? payementTableTitlesSmall : payementTableTitles,
          onTap: () {
            addPayement(
              facture: widget.facture,
            );
          },
        ),
        ...widget.facture.payements!.map(
          (payement) => isMobile
              ? TableRow(
                  //decoration: tableDecoration,
                  children: [
                    TableBodyMiddle(valeur: payement.libelle!),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(payement.montant),
                    ),
                    TableBodyLast(
                      items: [
                        if (payement.user!.equalTo(user: user!) &&
                            (payement.status != FluxFinancierStatus.valid) &&
                            hasPermission(
                                roles: roles,
                                permission:
                                    PermissionAlias.updateFluxFinancier.label))
                          (
                            label: Constant.edit,
                            onTap: () {
                              editPayement(payement: payement);
                            },
                            color: null, // couleur null
                          ),
                        (
                          label: Constant.detail,
                          onTap: () {
                            detailPayement(payement: payement);
                          },
                          color: null, // couleur null
                        ),
                      ],
                    ),
                  ],
                )
              : TableRow(
                  //decoration: tableDecoration,
                  children: [
                    TableBodyMiddle(valeur: payement.libelle!),
                    TableBodyMiddle(
                      valeur: Formatter.formatAmount(
                        payement.montant,
                      ),
                    ),
                    TableBodyMiddle(
                      valeur: payement.moyenPayement!.libelle,
                    ),
                    TableBodyMiddle(
                      valeur: getStringDate(
                        time: payement.dateOperation!,
                      ),
                    ),
                    Row(
                      children: [
                        if (payement.user!.equalTo(user: user!) &&
                            (payement.status != FluxFinancierStatus.valid) &&
                            hasPermission(
                                roles: roles,
                                permission:
                                    PermissionAlias.updateFluxFinancier.label))
                          IconButton(
                            onPressed: () {
                              editPayement(payement: payement);
                            },
                            icon: SvgPicture.asset(
                              AssetsIcons.edit,
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                            detailPayement(payement: payement);
                          },
                          icon: SvgPicture.asset(
                            AssetsIcons.detail,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
        ),
      ],
    );
  }
}
