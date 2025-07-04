import 'package:flutter/material.dart';
 import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/user_helper.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../../responsitvity/responsivity.dart';
import 'diagramme_baton.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/assets/asset_icon.dart';
import '../../../model/client/client_model.dart';
import '../../../model/facturation/facture_model.dart';
import '../../../model/facturation/proforma_model.dart';
import '../../../model/flux_financier/creance_model.dart';
import '../../../service/client_service.dart';
import '../../../service/facture_service.dart';
import '../../../service/proforma_service.dart';
import '../../../widget/dashbord_card.dart';
import 'package:gap/gap.dart';
import '../../../service/creance_service.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  Future<String>? _creanceFuture;
  Future<String>? _clientFuture;
  Future<String>? _factureUnpayeFuture;
  Future<String>? _proformaFuture;
  RoleModel? role; // Changé en nullable
  String? errMessage;
  bool _isLoading = true; // Ajouté pour gérer le chargement

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getRole();
    _creanceFuture = _loadCreance();
    _clientFuture = _loadClient();
    _factureUnpayeFuture = _loadFactureUnpaye();
    _proformaFuture = _loadProforma();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getRole() async {
    try {
      RoleModel roleprime = await AuthService().getRole();
      setState(() {
        role = roleprime;
      });
    } catch (e) {
      setState(() {
        errMessage = 'Erreur lors du chargement du rôle';
      });
    }
  }

  Future<String> _loadCreance() async {
    DateTime today = DateTime.now();
    DateTime debut = DateTime(today.year, today.month, today.day, 0, 0, 0);
    DateTime fin = DateTime(today.year, today.month, today.day, 23, 59, 59);

    try {
      List<CreanceModel> creanceData = (await CreanceService.getClaimAmount(
        debut: debut,
        fin: fin,
      ));
      return Formatter.formatAmount(creanceData.fold<double>(
        0.0,
        (total, creance) => total + creance.montantRestant.toDouble(),
      ));
    } catch (err) {
      setState(() {
        errMessage = err.toString();
      });
      return "0";
    }
  }

  Future<String> _loadClient() async {
    try {
      List<ClientModel> clientData =
          (await ClientService.getUnarchivedClients());
      return Formatter.formatAmount(clientData.length.toDouble());
    } catch (err) {
      setState(() {
        errMessage = err.toString();
      });
      return "0";
    }
  }

  Future<String> _loadFactureUnpaye() async {
    try {
      List<FactureModel> factureData =
          await FactureService.getUnPaidFacturesForDashboard();
      return Formatter.formatAmount(factureData.length.toDouble());
    } catch (err) {
      setState(() {
        errMessage = err.toString();
      });
      return "0";
    }
  }

  Future<String> _loadProforma() async {
    try {
      List<ProformaModel> factureData =
          (await ProformaService.getProformasAttente());
      return Formatter.formatAmount(factureData.length.toDouble());
    } catch (err) {
      setState(() {
        errMessage = err.toString();
      });
      return "0";
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading || role == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    List<Widget> items = [
      if (hasPermission(
          role: role!, permission: PermissionAlias.readCreance.label))
        DashboardInfo(
          icon: AssetsIcons.claim,
          title: "Créances du jour",
          futureValue: _creanceFuture!,
        ),
      if (hasPermission(
          role: role!, permission: PermissionAlias.readClient.label))
        DashboardInfo(
          icon: AssetsIcons.client,
          title: "Clients",
          futureValue: _clientFuture!,
        ),
      if (hasPermission(
          role: role!, permission: PermissionAlias.readFacture.label))
        DashboardInfo(
          icon: AssetsIcons.facture,
          title: "Factures impayés",
          futureValue: _factureUnpayeFuture!,
        ),
      if (hasPermission(
          role: role!, permission: PermissionAlias.readProforma.label))
        DashboardInfo(
          icon: AssetsIcons.waitInvoice,
          title: "Proformats en attente",
          futureValue: _proformaFuture!,
        ),
    ];

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Wrap(
                children: items
                    .map((item) => ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 260,
                            maxWidth: Responsive.isMobile(context)
                                ? double.infinity
                                : 350,
                          ),
                          child: item,
                        ))
                    .toList(),
              ),
              Gap(16),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollStartNotification) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: FinancialBarChart(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
