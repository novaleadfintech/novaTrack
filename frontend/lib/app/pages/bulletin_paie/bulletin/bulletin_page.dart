import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/bulletin_paie/bulletin/choose_period_page.dart';
import 'package:frontend/model/habilitation/role_model.dart';
import 'package:frontend/service/bulletin_service.dart';
import 'package:frontend/widget/add_element_button.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/bulletin_paie/bulletin_model.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import 'current_bulletin_table.dart';

class BulletinPage extends StatefulWidget {
  final RoleModel role;

  const BulletinPage({super.key, required this.role});

  @override
  State<BulletinPage> createState() => _ArchiveBulletinState();
}

class _ArchiveBulletinState extends State<BulletinPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  RoleModel? role;

  // 🔑 Ajouter une clé unique pour forcer le rebuild du FutureBuilder
  late Future<List<BulletinPaieModel>> _bulletinsFuture;

  @override
  void initState() {
    super.initState();
    role = widget.role;
    _bulletinsFuture =
        _loadBulletinData(); // ✅ Initialiser le Future une seule fois
  }

  /// Public method other pages can call to force a reload
  Future<void> reload() async {
    setState(() {
      _bulletinsFuture = _loadBulletinData(); // ✅ Créer un nouveau Future
    });
  }

  Future<List<BulletinPaieModel>> _loadBulletinData() async {
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
            AddElementButton(
              addElement: onEditBulletin,
              icon: Icons.list,
              label: "Générer les bulletins",
            ),
          ],
        ),
        const Gap(4),
        Expanded(
          child: FutureBuilder<List<BulletinPaieModel>>(
            future: _bulletinsFuture, // ✅ Utiliser le Future stocké
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return ErrorPage(
                  message: snapshot.error.toString(),
                  onPressed: () => setState(() {
                    _bulletinsFuture = _loadBulletinData(); // ✅ Recharger
                  }),
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
                          refresh: () => setState(() {
                            _bulletinsFuture =
                                _loadBulletinData(); // ✅ Recharger
                          }),
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
    showResponsiveDialog(
      context,
      content: ChoosePeriodPage(
        refresh: () async {
          // ✅ Recharger les données après mutation
          setState(() {
            _bulletinsFuture = _loadBulletinData();
          });
        },
      ),
      title: "Choisir la période de paie",
    );
  }
}
