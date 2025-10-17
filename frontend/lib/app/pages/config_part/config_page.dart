import 'package:flutter/material.dart';
 import 'package:frontend/app/pages/bulletin_paie/paid_calendar/paid_calendar_page.dart';
import 'package:frontend/app/pages/categories_paie/categorie_paie_page.dart';
import 'package:frontend/app/pages/configure_page_dialog.dart';
import 'package:frontend/app/pages/entreprise/entreprise_page.dart';
import 'package:frontend/app/pages/grille_salariale/grille_page.dart';
import 'package:frontend/app/pages/moyen_de_payement/moyen_payement_page.dart';
import 'package:frontend/app/pages/pays/pays_page.dart';
import 'package:frontend/app/pages/poste/poste_page.dart';
import 'package:frontend/app/pages/profil/profil_page.dart';
import 'package:frontend/app/pages/bulletin_paie/rubrique_bulletin/rubrique_page.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:frontend/widget/reponsive_conf_card.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../categories/categorie_page.dart';
import '../error_page.dart';
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
  late RoleModel role;
  bool isLoading = true;
  bool hasError = false;
  String? errMessage;
  Future<void> getRole() async {
    try {
      setState(() {
        isLoading = true;
      });
      role = await AuthService().getRole();
    } catch (error) {
      setState(() {
        errMessage = error.toString();
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    // setState(() {
    //   role = roleprime;
    // });
  }

  @override
  void initState() {
    getRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? const SizedBox.expand(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : (hasError)
            ? SizedBox.expand(
                child: ErrorPage(
                  message: errMessage ?? "Une erreur s'est produite",
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                      hasError = false;
                    });
                    await getRole();
                  },
                ),
              )
            : Column(
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
                                    title: "Libellés financier",
                                    content: LibelleFluxFinancierPage());
                              },
                              child: ResponsiveCard(
                                label: "Libellés financier",
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Moyens de payement",
                                  content: MoyenPaiementPage(),
                                );
                              },
                              child:
                                  ResponsiveCard(label: "Moyens de payement"),
                            ),
                            InkWell(
                              child: ResponsiveCard(
                                  label: "Catégories de partenaire"),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Catégories de partenaire",
                                  content: CategorieClientPage(),
                                );
                              },
                            ),
                            InkWell(
                              child:
                                  ResponsiveCard(label: "Catégories de paie"),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Catégories de paie",
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
                                  content: PaysPage(role: role),
                                );
                              },
                            ),
                            InkWell(
                              child: ResponsiveCard(label: "Poste"),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Poste",
                                  content: PostePage(),
                                );
                              },
                            ),
                            InkWell(
                              child: ResponsiveCard(
                                  label: "Rubriques de bulletin"),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Rubriques de bulletin",
                                  content: RubriquePaiePage(),
                                );
                              },
                            ),
                            InkWell(
                              child:
                                  ResponsiveCard(label: "Sections de bulletin"),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Sections de bulletin",
                                  content: SectionPage(),
                                );
                              },
                            ),
                            InkWell(
                              child: ResponsiveCard(
                                  label: "Rubriques - Catégorie de paie"),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Rubriques - Catégorie de paie",
                                  content: RubriqueCategoriePaie(),
                                );
                              },
                            ),
                            InkWell(
                              child:
                                  ResponsiveCard(label: "Profils utilisateur"),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Profils",
                                  content: ProfilPage(),
                                );
                              },
                            ),
                            if (hasPermission(
                                role: role,
                                permission:
                                    PermissionAlias.assignPermissionRole.label))
                              InkWell(
                                child: ResponsiveCard(label: "Habilitations"),
                                onTap: () {
                                  showResponsiveConfigPageDialogBox(
                                    context,
                                    title: "Habilitations",
                                    content: PermissionPage(),
                                  );
                                },
                              ),
                            InkWell(
                              child: ResponsiveCard(label: "Facturations"),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "facturations",
                                  content: FactureConfigPage(),
                                );
                              },
                            ),
                            if (hasPermission(
                                    role: role,
                                    permission:
                                        PermissionAlias.readEntreprise.label) ||
                                hasPermission(
                                    role: role,
                                    permission:
                                        PermissionAlias.manageEntreprise.label))
                              InkWell(
                                child: ResponsiveCard(label: "Entreprise"),
                                onTap: () {
                                  showResponsiveConfigPageDialogBox(
                                    context,
                                    title: "Entreprise",
                                    content: EntreprisePage(
                                      role: role,
                                    ),
                                  );
                                },
                              ),
                            InkWell(
                              child: ResponsiveCard(
                                label: "Grille salariale",
                              ),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Catégorie de paie",
                                  content: GrilleCategoriePaiePage(),
                                );
                              },
                            ),
                            InkWell(
                              child: ResponsiveCard(
                                label: "Calendrier de paie",
                              ),
                              onTap: () {
                                showResponsiveConfigPageDialogBox(
                                  context,
                                  title: "Calendrier de paie",
                                  content: PayCalendarPage(role: role),
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
