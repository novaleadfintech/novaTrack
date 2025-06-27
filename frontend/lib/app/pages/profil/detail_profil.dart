import 'package:flutter/material.dart';
  import '../../../model/habilitation/role_model.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_middle.dart';

class DetailProfilPage extends StatefulWidget {
  final RoleModel profil;
  const DetailProfilPage({
    super.key,
    required this.profil,
  });

  @override
  State<DetailProfilPage> createState() => _DetailProfilPageState();
}

class _DetailProfilPageState extends State<DetailProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Libellé",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.profil.libelle,
            ),
          ],
        ),
      ],
    );
  }
}
