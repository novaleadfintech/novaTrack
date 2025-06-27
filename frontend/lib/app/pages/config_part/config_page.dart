import 'package:flutter/material.dart';
import 'package:frontend/app/pages/categories_paie/categorie_paie_page.dart';
import 'package:frontend/app/pages/configure_page_dialog.dart';
import 'package:frontend/app/pages/entreprise/entreprise_page.dart';
import 'package:frontend/app/pages/moyen_de_payement/moyen_payement_page.dart';
import 'package:frontend/app/pages/pays/pays_page.dart';
import 'package:frontend/app/pages/profil/profil_page.dart';
import 'package:frontend/app/pages/bulletin_paie/rubrique_bulletin/rubrique_page.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:frontend/widget/reponsive_conf_card.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../categories/categorie_page.dart';
import '../facture_config/facture_config_page.dart';
import '../libelle_flux_financier/flux_libelle_page.dart';
import '../permission/habilitation.dart';
import '../rubrique_categorie/rubrique_categorie_page.dart';
import '../section_bulletin/section_page.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  List<RoleModel> roles = [];
  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
    setState(() {
      
    });
  }

  @override
  void initState() {
    getRoles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Wrap(
                spacing: 12,
                runSpacing: 12,
                runAlignment: WrapAlignment.start,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                 
                  InkWell(
                    onTap: () {
                      showResponsiveConfigPageDialogBox(context,
                          title: "Libellé financier",
                          content: LibelleFluxFinancierPage());
                    },
                    child: ResponsiveCard(
                      label: "Libellé financier",
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "Moyen de payement",
                        content: MoyenPaiementPage(),
                      );
                    },
                    child: ResponsiveCard(label: "Moyen de payement"),
                  ),
                  InkWell(
                    child: ResponsiveCard(label: "Catégorie de partenaire"),
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "Catégorie de partenaire",
                        content: CategorieClientPage(),
                      );
                    },
                  ),
                  InkWell(
                    child: ResponsiveCard(label: "Catégorie de paie"),
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "Catégorie de paie",
                        content: CategoriePaiePage(),
                      );
                    },
                  ),
                  InkWell(
                    child: ResponsiveCard(label: "Pays"),
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "Pays",
                        content: PaysPage(),
                      );
                    },
                  ),
                  InkWell(
                    child: ResponsiveCard(label: "Rubrique de bulletin"),
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "Rubrique de bulletin",
                        content: RubriquePaiePage(),
                      );
                    },
                  ),
                  InkWell(
                    child: ResponsiveCard(label: "Section de bulletin"),
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "Section de bulletin",
                        content: SectionPage(),
                      );
                    },
                  ),
                  InkWell(
                    child:
                        ResponsiveCard(label: "Rubrique - Catégorie de paie"),
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "Rubrique - Catégorie de paie",
                        content: RubriqueCategoriePaie(),
                      );
                    },
                  ),
                  InkWell(
                    child: ResponsiveCard(label: "Profil utilisateur"),
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "Profils",
                        content: ProfilPage(),
                      );
                    },
                  ),
                  if (hasPermission(
                      roles: roles,
                      permission: PermissionAlias.assignPermissionRole.label))
                    InkWell(
                      child: ResponsiveCard(label: "Habilitation"),
                      onTap: () {
                        showResponsiveConfigPageDialogBox(
                          context,
                          title: "Habilitation",
                          content: PermissionPage(),
                        );
                      },
                    ),
                  InkWell(
                    child: ResponsiveCard(label: "Facturation"),
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "facturation",
                        content: FactureConfigPage(),
                      );
                    },
                  ),
                  InkWell(
                    child: ResponsiveCard(label: "Entreprise"),
                    onTap: () {
                      showResponsiveConfigPageDialogBox(
                        context,
                        title: "Entreprise",
                        content: EntreprisePage(),
                      );
                    },
                  ),
                ]),
          ),
        ),
      ],
    );
  }
}
