import 'package:flutter/material.dart';
  import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:frontend/model/personnel/poste_model.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../service/poste_service.dart';
import '../../../../widget/add_element_button.dart';
 import '../../../../widget/research_bar.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../app_dialog_box.dart';
import '../../error_page.dart';
import 'add_echelon.dart';

class EchelonPage extends StatefulWidget {
  const EchelonPage({
    super.key,
  });

  @override
  State<EchelonPage> createState() => _EchelonPageState();
}

class _EchelonPageState extends State<EchelonPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<PosteModel> posteData = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  late Future<void> _futureRoles;
  late RoleModel role;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _futureRoles = getRole();
    _loadEchelon();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadEchelon() async {
    try {
      posteData = await PosteService.getPostes();
    } catch (error) {
      setState(() {
        errorMessage = error.toString();

        hasError = true;
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  List<PosteModel> filterPoste() {
    return posteData.where((poste) {
      return poste.libelle
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onClickAddFluxButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau échelon",
      content: AddEchelon(
        refresh: _loadEchelon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<PosteModel> filteredData = filterPoste();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                var canCreate = hasPermission(
                  role: role,
                  permission: PermissionAlias.createPoste.label,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ResearchBar(
                      hintText: "Rechercher par libellé",
                      controller: _researchController,
                    ),
                    // if (canCreate)
                    Container(
                      alignment: Alignment.centerRight,
                      child: AddElementButton(
                        addElement: onClickAddFluxButton,
                        icon: Icons.add_outlined,
                        isSmall: true,
                        label: "Ajouter un libellé",
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const Gap(4),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            )
          else if (hasError)
            ErrorPage(
              message: errorMessage ?? "Erreur lors du chargement des données.",
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
                await _loadEchelon();
              },
            )
          // else
          //   Expanded(
          //     child: filteredData.isEmpty
          //         ? NoDataPage(
          //             data: filteredData,
          //             message: "Aucun",
          //           )
          //         : Column(
          //             children: [
          //               Expanded(
          //                 child: Container(
          //                     color: Theme.of(context).colorScheme.surface,
          //                     child: Column(
          //                       children: [],
          //                     )
          //                     //  EchelonTable(
          //                     //   poste: getPaginatedData(
          //                     //       data: filteredData, currentPage: currentPage),
          //                     //   refresh: _loadEchelon,
          //                     // ),
          //                     ),
          //               ),
          //               if (filteredData.isNotEmpty)
          //                 PaginationSpace(
          //                   currentPage: currentPage,
          //                   onPageChanged: updateCurrentPage,
          //                   filterDataCount: filteredData.length,
          //                 ),
          //             ],
          //           ),
          //   ),
        ],
      ),
    );
  }
}
