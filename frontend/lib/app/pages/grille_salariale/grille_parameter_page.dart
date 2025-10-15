import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
 import 'package:frontend/app/pages/configure_page_dialog.dart';
import 'package:frontend/app/pages/grille_salariale/classe/classe_page.dart';
import 'package:frontend/app/pages/grille_salariale/echelons/echelon_page.dart';
import 'package:frontend/widget/app_tile_clickable.dart';

import 'add_edit_valeur_indiciaire.dart';

class GrilleParameterPage extends StatelessWidget {
  const GrilleParameterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTileClickable(
          tileTitle: "Classes",
          onClick: () {
            showResponsiveConfigPageDialogBox(
              context,
              content: ClassePage(),
              title: "Classes de grille salariale",
            );
          },
        ),
        AppTileClickable(
          tileTitle: "Echélons",
          onClick: () {
            showResponsiveConfigPageDialogBox(
              context,
              content: EchelonPage(),
              title: "Echelons de la grille salariale",
            );
          },
        ),
        AppTileClickable(
          tileTitle: "Valeur indiciaire",
          onClick: () {
            showResponsiveDialog(
              context,
              content: AddOrEditValeurIndiciaire(),
              title: "Valeur indiciaire",
            );
          },
        ),
      ],
    );
  }
}
