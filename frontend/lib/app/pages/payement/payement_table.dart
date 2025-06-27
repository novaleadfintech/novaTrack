import 'package:flutter/material.dart';
import '../utils/payement_util.dart';
import '../../responsitvity/responsivity.dart';
import '../../../model/facturation/facture_model.dart';
import '../../../widget/payement_tile.dart';
import '../../../widget/table_header.dart';

class PayementTable extends StatefulWidget {
  final List<FactureModel> paginatedFacturesData;
  final Future<void> Function() refresh;

  const PayementTable({
    super.key,
    required this.refresh,
    required this.paginatedFacturesData,
  });

  @override
  State<PayementTable> createState() => _PayementTableState();
}

class _PayementTableState extends State<PayementTable> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Table(
          columnWidths: {
            3: const FixedColumnWidth(173),
            2: isMobile ? const FixedColumnWidth(23) : const FlexColumnWidth(),
          },
          children: [
            tableHeader(
              context,
              tablesTitles: isMobile
                  ? payementFactureTableTitlesSmall
                  : payementFactureTableTitles,
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.paginatedFacturesData
                  .map(
                    (facture) => PayementTile(
                      facture: facture,
                      refresh: widget.refresh,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
