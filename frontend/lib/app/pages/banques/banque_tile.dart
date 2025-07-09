import 'package:flutter/material.dart';
import 'package:frontend/app/pages/banques/edit_banque.dart';
import 'package:frontend/model/entreprise/type_canaux_paiement.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../app_dialog_box.dart';
import '../../../helper/amout_formatter.dart';
import '../../../model/entreprise/banque.dart';
import '../../../style/app_color.dart';
import 'package:gap/gap.dart';

import '../custom_popup.dart';
import 'choose_trans_duration.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
 
class BanqueTile extends StatefulWidget {
  final VoidCallback refresh;
  final BanqueModel banque;
  const BanqueTile({
    super.key,
    required this.banque,
    required this.refresh,
  });

  @override
  State<BanqueTile> createState() => _BanqueTileState();
}

class _BanqueTileState extends State<BanqueTile> {
  late Future<void> _futureRoles;
  late RoleModel role;
  

  @override
  void initState() {
    super.initState();
    _futureRoles = getRole();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth > 600
            ? (constraints.maxWidth / 2) - 32
            : double.infinity;

        return Card(
          elevation: 0,
          semanticContainer: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            width: cardWidth,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.banque.logo != null) ...[
                        Container(
                          decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(widget.banque.logo!),
                              )),
                          height: 32,
                          width: 32,
                        ),
                      ] else
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                          ),
                          height: 32,
                          width: 32,
                        ),
                      const Gap(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.banque.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  widget.banque.country!.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              widget.banque.type ==
                                      CanauxPaiement.operateurMobile
                                  ? "N° ${widget.banque.numCompte}"
                                  :
                               "N° ${widget.banque.codeBanque}-${widget.banque.codeGuichet}-${widget.banque.codeBIC}-${widget.banque.numCompte}-${widget.banque.cleRIB}",
                              overflow: TextOverflow.fade,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solde réel : ${Formatter.formatAmount(widget.banque.soldeReel)} FCFA',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Solde théorique : ${Formatter.formatAmount(widget.banque.soldeTheorique)} FCFA',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  FutureBuilder<void>(
                    future: _futureRoles,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return const SizedBox();
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (hasPermission(
                                role: role,
                                permission: PermissionAlias.updateBanque.label))
                              ElevatedButton(
                                onPressed: () {
                                  editBanqueSolde();
                                },
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: AppColor.adaptiveModificationColor(
                                      context),
                                ),
                              ),
                            const Gap(4),

                            if (hasPermission(
                                role: role,
                                permission: PermissionAlias
                                    .exportBanqueTransaction.label))
                              Tooltip(
                                message: 
                                    "Obtenir les transactions du canal de paiement",
                                child: InkWell(
                                  onTap: () {
                                    _downloadTransactions();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: AppColor.primaryColor,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      "PDF",
                                      style: TextStyle(
                                        color: AppColor.whiteColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void editBanqueSolde() {
    showResponsiveDialog(
      context,
      content: EditBanquePage(
        refresh: widget.refresh,
        banque: widget.banque,
      ),
      title: "Modifier le canal de paiement",
    );
  }

  void _downloadTransactions() {
    showCustomPoppup(
      context,
      content: Column(
        children: [
          ChooseTransactionDuration(
            banque: widget.banque,
          ),
        ],
      ),
      title: "Choisir la période des transactions",
    );
  }
}
