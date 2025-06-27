import 'package:flutter/material.dart';
import 'package:frontend/model/entreprise/banque.dart';

class MoreDatailBanquePage extends StatefulWidget {
  final BanqueModel banque;
  const MoreDatailBanquePage({
    super.key,
    required this.banque,
  });

  @override
  State<MoreDatailBanquePage> createState() => _MoreDatailBanquePageState();
}

class _MoreDatailBanquePageState extends State<MoreDatailBanquePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
