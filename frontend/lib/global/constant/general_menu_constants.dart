import 'package:flutter/material.dart';
import 'package:frontend/app/pages/banques/banque_page.dart';
import 'package:frontend/app/pages/bulletin_paie/bulletin_page.dart';
import 'package:frontend/app/pages/config_part/config_page.dart';
import 'package:frontend/app/pages/creance/creance_page.dart';
import 'package:frontend/app/pages/utilisation/user_page.dart';
import '../../app/pages/client/client_page.dart';
import '../../app/pages/dashboard/dashboard_page.dart';
import '../../app/pages/facturation/facture_page_layout.dart';
import '../../app/pages/flux_financier/flux_financier_layout.dart';
import '../../app/pages/payement/payement_page.dart';
 import '../../app/pages/personnel/personnel_page.dart';
import '../../app/pages/service/service_page.dart';
import '../../helper/assets/asset_icon.dart';
import '../../helper/user_helper.dart';
import '../../model/habilitation/role_model.dart';
import 'module_alias.dart';

class Menu {
  static String tableauBord = "Tableau de bord";
  static String client = "Partenaire";
  static String services = "Services";
  static String personnel = "Personnel";
  static String facturation = "Facturation";
  static String payement = "Payements";
  static String fluxFinancier = "Flux financiers";
  static String config = "Configurations";
  static String creance = "Créances";
  static String utilisation = "Utilisateurs";
  static String bulletin = "Bulletin de paie";
  static String comptebancaires = "Canaux de paiement";
}

// Icônes et titres associés
final allMenuItems = [
  (Menu.tableauBord, AssetsIcons.dashboard, 0),
  (Menu.client, AssetsIcons.client, 1),
  (Menu.services, AssetsIcons.service, 2),
  (Menu.personnel, AssetsIcons.personnel, 3),
  (Menu.facturation, AssetsIcons.facture, 4),
  (Menu.payement, AssetsIcons.payment, 5),
  (Menu.fluxFinancier, AssetsIcons.flux, 6),
  (Menu.creance, AssetsIcons.claim, 7),
  (Menu.config, AssetsIcons.fluxLibelle, 8),
  (Menu.comptebancaires, AssetsIcons.bank, 9),
  (Menu.bulletin, AssetsIcons.facture, 10),
  (Menu.utilisation, AssetsIcons.user, 11),
];

// Pages correspondantes
final allPages = <Widget>[
  const DashBoardPage(),
  const ClientPage(),
  const ServicePage(),
  const PersonnelPage(),
  const FacturePageLayout(),
  const PayementPage(),
  const FluxFinancierLayout(),
  const CreancePage(),
  const ConfigPage(),
  const BanquePage(),
  const BulletinLayout(),
  const UserPage(),
];

// Permissions requises pour chaque menu (par alias)
final Map<String, List<String>> menuPermissions = {
  Menu.client: [ModuleAlias.client.label],
  Menu.services: [ModuleAlias.service.label],
  Menu.personnel: [ModuleAlias.personnel.label],
  Menu.facturation: [
    ModuleAlias.facturation.label,
  ],
  Menu.payement: [ModuleAlias.fluxFinancier.label],
  Menu.fluxFinancier: [ModuleAlias.fluxFinancier.label],
  Menu.config: [ModuleAlias.config.label],
  Menu.creance: [ModuleAlias.facturation.label],
  Menu.utilisation: [ModuleAlias.utilisateur.label],
  Menu.bulletin: [ModuleAlias.bulletin.label],
  Menu.comptebancaires: [ModuleAlias.banque.label],
};

// Fonction de filtrage en fonction des rôles
(List<(String, String, int)>, List<Widget>) getMenuAndPages(
    List<RoleModel> roles) {
  List<(String, String, int)> filteredMenu = [];
  List<Widget> filteredPages = [];

  for (int i = 0; i < allMenuItems.length; i++) {
    final menuLabel = allMenuItems[i].$1;
    final modules = menuPermissions[menuLabel];

    final hasAccess = modules == null ||
        modules.any((m) => hasModule(roles: roles, module: m));

    if (hasAccess) {
      filteredMenu.add((menuLabel, allMenuItems[i].$2, filteredMenu.length));
      filteredPages.add(allPages[i]);
    }
  }

  return (filteredMenu, filteredPages);
}
