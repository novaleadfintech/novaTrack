import 'package:flutter/material.dart';
import 'package:frontend/service/facture_service.dart';
import '../no_data_page.dart';
import 'payement_table.dart';
import '../../../global/global_value.dart';
import '../../../helper/paginate_data.dart';
import '../../../model/facturation/facture_model.dart';
import '../../../widget/pagination.dart';
import 'package:gap/gap.dart';
import '../../../widget/research_bar.dart';
import '../error_page.dart';

class PayementPage extends StatefulWidget {
  const PayementPage({super.key});

  @override
  State<PayementPage> createState() => _PayementPageState();
}

class _PayementPageState extends State<PayementPage> {
  final TextEditingController _researchController = TextEditingController();
  String searchQuery = "";
  int currentPage = GlobalValue.currentPage;
  List<FactureModel> payementData = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    _researchController.addListener(_onSearchChanged);
    _loadPayementData();
    super.initState();
  
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadPayementData() async {
    try {
      setState(() {
        isLoading = true;
      });
      payementData = await FactureService.getPayementFactures();
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    setState(() {});
  }

  List<FactureModel> filteredPayementData() {
    return payementData.where((payement) {
      bool matchesSearch = payement.reference
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          payement.client!
              .toStringify()
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim());

      return matchesSearch;
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FactureModel> filteredData = filteredPayementData();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResearchBar(
                hintText: "Rechercher par client, ref",
                controller: _researchController,
              ),
              IconButton(
                onPressed: () async {
                  await _loadPayementData();
                },
                icon: Icon(
                  Icons.refresh,
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
                message:
                    errorMessage ?? 'Erreur lors du chargement des données',
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                  await _loadPayementData();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: payementData,
                      message: "Aucune facture à payer",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surfaceBright,
                            child: PayementTable(
                              paginatedFacturesData: getPaginatedData(
                                data: filteredData,
                                currentPage: currentPage,
                              ),
                              refresh: _loadPayementData,
                            ),
                          ),
                        ),
                        if (filteredData.isNotEmpty)
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
