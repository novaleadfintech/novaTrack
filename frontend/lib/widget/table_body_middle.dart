import 'package:flutter/material.dart';

class TableBodyMiddle extends StatelessWidget {
  final String valeur;
  const TableBodyMiddle({
    super.key,
    required this.valeur,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ).copyWith(
        right: 12,
        left: 8,
      ),
      child: Text(
        valeur,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class TabledetailBodyMiddle extends StatelessWidget {
  final String valeur;
  final bool isbold;
  const TabledetailBodyMiddle({
    super.key,
    required this.valeur,
    this.isbold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ).copyWith(
        right: 12,
        left: 8,
      ),
      child: Text(
        valeur,
        style: TextStyle(
          fontWeight: isbold ? FontWeight.bold : FontWeight.w400,
        ),
      ),
    );
  }
}
