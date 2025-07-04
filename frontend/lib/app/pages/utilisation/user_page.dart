import 'package:flutter/material.dart';
import 'package:frontend/model/habilitation/role_model.dart';
import '../../../auth/authentification_token.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/habilitation/user_model.dart';
import '../app_dialog_box.dart';
import 'add_user_page.dart';
import 'user_table.dart';
import '../no_data_page.dart';
import '../../../global/global_value.dart';
import '../../../helper/paginate_data.dart';
import '../../../model/common_type.dart';
import '../../../service/user_service.dart';
import '../../../widget/pagination.dart';
import 'package:gap/gap.dart';
import '../../../widget/add_element_button.dart';
import '../../../widget/research_bar.dart';
import '../error_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _researchController = TextEditingController();

  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;

  RoleModel? role;
  bool isRoleLoading = true; 

  List<String> selectedFilterOptions = [
    "Tout",
    Sexe.F.label,
    Sexe.M.label,
  ];

  @override
  void initState() {
    super.initState();
    getRole();
    _researchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  Future<List<UserModel>> _fetchUserData() async {
    return await UserService.getUsers();
  }

  List<UserModel> _filterUserData(List<UserModel> userData) {
    return userData.where((user) {
      final personnel = user.personnel;
      if (personnel == null) return false;

      final nom = personnel.nom.toLowerCase();
      final prenom = personnel.prenom.toLowerCase();
      final searchLower = searchQuery.toLowerCase().trim();

      bool matchesSearch =
          nom.contains(searchLower) || prenom.contains(searchLower);

      return matchesSearch;
    }).toList();
  }

  void _onAddUserPressed() {
    showResponsiveDialog(
      context,
      title: "Nouveau utilisateur",
      content: AddUserPage(
        refresh: () async {
          setState(() {});
        },
      ),
    );
  }

  Future<void> getRole() async {
    try {
      RoleModel? result = await AuthService().getRole();
      setState(() {
        role = result;
        isRoleLoading = false;
      });
    } catch (e) {
      setState(() {
        isRoleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un loader pendant le chargement du rôle
    if (isRoleLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
              if (role != null &&
                  hasPermission(
                      role: role!,
                      permission: PermissionAlias.assignRolePersonnel.label))
                Container(
                  alignment: Alignment.centerRight,
                  child: AddElementButton(
                    addElement: _onAddUserPressed,
                    icon: Icons.add_outlined,
                    label: "Ajouter un utilisateur",
                  ),
                ),
            ],
          ),
          const Gap(4),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return ErrorPage(
                    message: snapshot.error.toString(),
                    onPressed: () => setState(() {}),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const NoDataPage(
                    data: [],
                    message: "Aucun utilisateur trouvé",
                  );
                }

                final filteredData = _filterUserData(snapshot.data!);

                return Column(
                  children: [
                    Expanded(
                      child: filteredData.isEmpty
                          ? NoDataPage(
                              data: filteredData,
                              message: "Aucun utilisateur trouvé",
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: UserTable(
                                role: role!,
                                paginatedUserData: getPaginatedData(
                                  data: filteredData,
                                  currentPage: currentPage,
                                ),
                                refresh: () async {
                                  setState(() {});
                                },
                              ),
                            ),
                    ),
                    if (filteredData.isNotEmpty)
                      PaginationSpace(
                        filterDataCount: filteredData.length,
                        currentPage: currentPage,
                        onPageChanged: updateCurrentPage,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
