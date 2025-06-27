import 'package:flutter/material.dart';
import '../model/client/client_model.dart';

class TableBodyFirst extends StatelessWidget {
  final ClientModel client;

  const TableBodyFirst({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12).copyWith(left: 8),
      child: Text(
        client.toStringify(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
