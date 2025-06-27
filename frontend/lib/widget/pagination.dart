import 'package:flutter/material.dart';
import 'package:frontend/style/app_color.dart';
import 'package:gap/gap.dart';
import '../global/global_value.dart';
import '../style/app_style.dart';

class PaginationSpace extends StatefulWidget {
  final int filterDataCount;
  final int itemsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const PaginationSpace({
    super.key,
    this.itemsPerPage = GlobalValue.nbrePerPage,
    required this.filterDataCount,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  State<PaginationSpace> createState() => _PaginationSpaceState();
}

class _PaginationSpaceState extends State<PaginationSpace> {
  int get totalPages => (widget.filterDataCount / widget.itemsPerPage).ceil();

  void nextPage() {
    if (widget.currentPage < totalPages - 1) {
      widget.onPageChanged(widget.currentPage + 1);
    }
  }

  void previousPage() {
    if (widget.currentPage > 0) {
      widget.onPageChanged(widget.currentPage - 1);
    }
  }

  /// Affiche le nombre d'éléments visibles sous forme `x/y`
  String get currentPageItemsInfo {
    int end = (widget.currentPage + 1) * widget.itemsPerPage;
    if (end > widget.filterDataCount) {
      end = widget.filterDataCount;
    }
    return "$end / ${widget.filterDataCount}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton Précédent (affiché seulement si on n'est PAS sur la première page)
          if (widget.currentPage > 0)
            Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.onSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: InkWell(
                onTap: previousPage,
                child: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          const SizedBox(width: 8),
          // Affichage du nombre d'éléments visibles

          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            
            child: Text(
              currentPageItemsInfo,
              style: DestopAppStyle.paginationNumberStyle.copyWith(
                color: AppColor.blackColor,
              ),
            ),
          ),
          Gap(8),
          // Bouton Suivant (affiché seulement si on n'est PAS sur la dernière page)
          if (widget.currentPage < totalPages - 1)
            Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.onSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: InkWell(
                onTap: nextPage,
                child: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
