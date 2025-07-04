import 'package:flutter/material.dart';
import 'package:frontend/model/pays_model.dart';
 import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../service/pays_service.dart';
import '../app_dialog_box.dart';
import '../../../widget/add_element_button.dart';
import "../error_page.dart";
import 'package:gap/gap.dart';
import '../../../global/global_value.dart';
import '../../../helper/paginate_data.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../no_data_page.dart';
import 'add_pays_page.dart';
import 'pays_table.dart';

class PaysPage extends StatefulWidget {
  final RoleModel role;
  const PaysPage({
    super.key,
    required this.role,
  });

  @override
  State<PaysPage> createState() => _ServicePageState();
}

class _ServicePageState extends State<PaysPage> {
  final TextEditingController _researchController = TextEditingController();
  late RoleModel role;

  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;
  List<PaysModel> paysData = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    role = widget.role;
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _loadPaysData();
    // getRole();
  }

  // Future<void> getRole() async {
  //   role = await AuthService().getRole();
  // }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadPaysData() async {
    try {
      setState(() {
        isLoading = true;
      });
      paysData = await PaysService.getAllPays();
    } catch (error) {
      setState(() {
        hasError = true;
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<PaysModel> filterPaysData() {
    return paysData.where((pays) {
      bool matchesSearch =
          pays.name.toLowerCase().contains(searchQuery.toLowerCase().trim());
      return matchesSearch;
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onClickAddServiceButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau pays",
      content: AddPaysPage(refresh: _loadPaysData),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<PaysModel> filteredData = filterPaysData();

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 0,
        left: 8,
        right: 8,
      ),
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
              if (hasPermission(
                role: role,
                permission: PermissionAlias.createPays.label,
              ))
                Container(
                  alignment: Alignment.centerRight,
                  child: AddElementButton(
                    addElement: onClickAddServiceButton,
                    icon: Icons.add_outlined,
                    label: "Ajouter un pays",
                  ),
                ),
            ],
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
                message: errorMessage!,
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                  await _loadPaysData();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: paysData,
                      message: "Aucun pays",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: PaysTable(
                              role: widget.role,
                              paginatedServiceData: getPaginatedData(
                                data: filteredData,
                                currentPage: currentPage,
                              ),
                              refresh: _loadPaysData,
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
