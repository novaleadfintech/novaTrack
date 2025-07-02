import 'package:flutter/material.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../service/banque_service.dart';
import '../../../auth/authentification_token.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/entreprise/banque.dart';
import '../app_dialog_box.dart';
import '../../../widget/add_element_button.dart';
import "../error_page.dart";
import 'package:gap/gap.dart';
import '../../../global/global_value.dart';
import '../../../helper/paginate_data.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../no_data_page.dart';
import 'add_banque.dart';
import 'banque_tile.dart';

class BanquePage extends StatefulWidget {
  const BanquePage({super.key});

  @override
  State<BanquePage> createState() => _BanquePageState();
}

class _BanquePageState extends State<BanquePage> {
  final TextEditingController _researchController = TextEditingController();
  late Future<void> _futureRoles;
  late RoleModel role;

  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;
  List<BanqueModel> banqueData = [];
  bool isLoading = true;
  bool hasError = false;
  String? errMessage;

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _futureRoles = getRole();
    _loadBanqueData();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadBanqueData() async {
    try {
      setState(() {
        isLoading = true;
      });
      banqueData = await BanqueService.getAllBanques();
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
  }

  List<BanqueModel> filterBanqueData() {
    return banqueData.where((banque) {
      bool matchesSearch =
          banque.name.toLowerCase().contains(searchQuery.toLowerCase().trim());
      return matchesSearch;
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onClickAddBanqueButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau canal de paiement",
      content: AddBanquePage(refresh: _loadBanqueData),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<BanqueModel> filteredData = filterBanqueData();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<void>(
            future: _futureRoles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              } else if (snapshot.hasError) {
                return const SizedBox();
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ResearchBar(
                      hintText: "Rechercher par nom ",
                      controller: _researchController,
                    ),
                    if (hasPermission(
                        role: role,
                        permission: PermissionAlias.createBanque.label))
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: AddElementButton(
                            addElement: onClickAddBanqueButton,
                            icon: Icons.add_outlined,
                            label: "Ajouter un canal de paiement",
                          ),
                        ),
                      ),
                  ],
                );
              }
            },
          ),
          const Gap(4),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (hasError)
            Expanded(
              child: ErrorPage(
                message: errMessage ?? "Une erreur s'est produite",
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                  await _loadBanqueData();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: banqueData,
                      message: "Aucun canal de paiement",
                    )
                  : Column(
                      crossAxisAlignment: getPaginatedData(
                                      data: filteredData,
                                      currentPage: currentPage)
                                  .length >
                              1
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: getPaginatedData(
                                      data: filteredData,
                                      currentPage: currentPage)
                                  .map(
                                    (banque) => BanqueTile(
                                      banque: banque,
                                      refresh: _loadBanqueData,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        PaginationSpace(
                          currentPage: currentPage,
                          onPageChanged: updateCurrentPage,
                          filterDataCount: filteredData.length,
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
