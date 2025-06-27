import 'package:custom_dropdown_search/custom_dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../app/pages/app_dialog_box.dart';
import '../app/pages/categories/add_categorie.dart';
import '../helper/assets/asset_icon.dart';
import '../model/client/categorie_model.dart';
import '../service/categorie_service.dart';
import '../style/app_color.dart';
import '../style/app_style.dart';
import 'validate_button.dart';
import 'package:gap/gap.dart';

class CategorieFutureCustomDropDownField extends StatefulWidget {
  final String label;
  final CategorieModel? selectedItem;
  final void Function(CategorieModel?) onChanged;
  final String Function(CategorieModel) itemsAsString;

  const CategorieFutureCustomDropDownField({
    super.key,
    required this.label,
    required this.selectedItem,
    required this.onChanged,
    required this.itemsAsString,
  });

  @override
  State<CategorieFutureCustomDropDownField> createState() =>
      _CustomDropDownFieldState();
}

class _CustomDropDownFieldState
    extends State<CategorieFutureCustomDropDownField> {
  List<CategorieModel> items = [];
  bool isLoading = false;
  bool hasError = false;

  final GlobalKey<DropdownSearchState<CategorieModel>> _dropdownKey =
      GlobalKey<DropdownSearchState<CategorieModel>>();

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final data = await CategorieService.getCategories();
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  void onAddCategory() {
    _dropdownKey.currentState?.closeDropDownSearch();
    showResponsiveDialog(
      context,
      content: AddCategoriePage(
        refresh: refreshData,
      ),
      title: "Nouvelle catégorie",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                textAlign: TextAlign.left,
                style: DestopAppStyle.fieldTitlesStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              Text(
                "*",
                style: DestopAppStyle.normalText.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          const Gap(4),
          SizedBox(
            height: 40,
            child: DropdownSearch<CategorieModel>(
              key: _dropdownKey,
              popupProps: PopupProps.menu(
                fit: FlexFit.loose,
                showSelectedItems: true,
                showSearchBox: false,
                containerBuilder: (context, popupWidget) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (!isLoading && !hasError && items.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: onAddCategory,
                                icon: SvgPicture.asset(
                                  AssetsIcons.simpleAdd,
                                ),
                              ),
                            ],
                          ),
                        Expanded(child: popupWidget),
                      ],
                    ),
                  );
                },
                itemBuilder: (context, item, isSelected) {
                  return ListTile(
                    title: Text(widget.itemsAsString(item)),
                    trailing: isSelected
                        ? Icon(
                            Icons.circle_notifications_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  );
                },
                emptyBuilder: (context, searchEntry) {
                  return Column(
                    children: [
                      const Expanded(
                        child: Center(
                          child: Text("Aucune catégorie"),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ValidateButton(
                              onPressed: onAddCategory,
                              libelle: "Ajouter",
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                errorBuilder: (context, searchEntry, exception) {
                  return Center(
                    child: Column(
                      children: [
                        const Text("Erreur lors du chargement des données"),
                        IconButton(
                          icon: SvgPicture.asset(AssetsIcons.refresh),
                          onPressed: () async {
                            await _loadData();
                          },
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, searchEntry) {
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              asyncItems: (String filter) async {
                if (!isLoading) {
                  await _loadData();
                }
                return items;
              },
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColor.popGrey,
                      width: 0.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColor.popGrey,
                      width: 0.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
              ),
              onChanged: (CategorieModel? newValue) {
                if (!isLoading && !hasError) {
                  widget.onChanged(newValue);
                }
              },
              selectedItem: widget.selectedItem,
              itemAsString: widget.itemsAsString,
              compareFn: (CategorieModel? item, CategorieModel? selectedItem) =>
                  item == selectedItem,
            ),
          ),
        ],
      ),
    );
  }
}
