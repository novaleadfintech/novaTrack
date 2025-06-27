import 'package:flutter/material.dart';

class ClickabeTile extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  const ClickabeTile({
    super.key,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
    );
  }
}
