// import 'package:flutter/material.dart';
// import '../app_tab_bar.dart';
// import 'input_libelle_page.dart';
// import 'output_libelle_page.dart';

// import '../../../model/flux_financier/type_flux_financier.dart';

// class LibelleFluxFinancierLayout extends StatefulWidget {
//   const LibelleFluxFinancierLayout({super.key});

//   @override
//   State<LibelleFluxFinancierLayout> createState() => _FacturePageState();
// }

// class _FacturePageState extends State<LibelleFluxFinancierLayout> {
//   List<String> tabbarTiles = [
//     FluxFinancierType.input.label,
//     FluxFinancierType.output.label,
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: AppTabBar(
//             tabTitles: tabbarTiles,
//             views: const [
//               InputPage(),
//               OutputPage(),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }
