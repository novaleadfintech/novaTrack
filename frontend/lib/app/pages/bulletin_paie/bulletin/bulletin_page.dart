import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/pages/bulletin_paie/bulletin/preparation_bulletin.dart';
import 'package:frontend/app/pages/configure_page_dialog.dart';
import 'package:frontend/model/habilitation/role_model.dart';
import 'package:frontend/service/bulletin_service.dart';
import 'package:gap/gap.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/assets/asset_icon.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/bulletin_paie/bulletin_model.dart';
import '../../../../widget/app_action_button.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import 'current_bulletin_table.dart';

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _ArchiveBulletinState();
}

class _ArchiveBulletinState extends State<BulletinPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  RoleModel? role;

  @override
  void initState() {
    super.initState();
    getRole();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
    setState(() {});
  }

  Future<List<BulletinPaieModel>> _loadServiceData() async {
    try {
      return await BulletinService.getCurrentBulletins();
    } catch (error) {
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un indicateur de chargement tant que le rôle n'est pas encore chargé
    if (role == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResearchBar(
              hintText: "Rechercher par nom",
              controller: _researchController,
            ),
            AppActionButton(
              onPressed: () {
                onEditBulletin();
              },
              child: SvgPicture.asset(
                AssetsIcons.validInvoice,
                height: 20,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        const Gap(4),
        Expanded(
          child: FutureBuilder<List<BulletinPaieModel>>(
            future: _loadServiceData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return ErrorPage(
                  message: snapshot.error.toString(),
                  onPressed: () => setState(() {}),
                );
              } else if (snapshot.hasData) {
                final data = snapshot.data!;
                if (data.isEmpty) {
                  return NoDataPage(
                    data: data,
                    message: "Aucun bulletin de paie",
                  );
                }

                final filteredData = data.where((item) {
                  return item.salarie.personnel
                      .toStringify()
                      .contains(_researchController.text.trim());
                }).toList();

                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: CurrentBulletinTable(
                          role: role!,
                          paginatedCurrentBulletintData: getPaginatedData(
                            data: filteredData,
                            currentPage: currentPage,
                          ),
                          refresh: () => setState(() {}),
                        ),
                      ),
                    ),
                    PaginationSpace(
                      currentPage: currentPage,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      filterDataCount: filteredData.length,
                    ),
                  ],
                );
              }
              return const Center(child: Text("État inattendu"));
            },
          ),
        ),
      ],
    );
  }

  void onEditBulletin() {
    showResponsiveConfigPageDialogBox(
      context,
      content: PreparationBulletinPage(),
      title: "Préparation des bulletin",
    );
  }
}
