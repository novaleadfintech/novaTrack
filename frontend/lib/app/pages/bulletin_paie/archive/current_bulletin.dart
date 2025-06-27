// import 'package:flutter/material.dart';
// import 'package:frontend/app/pages/bulletin_paie/add_bulletin.dart';
// import 'package:frontend/app/pages/no_data_page.dart';
// import 'package:frontend/model/bulletin_paie/Etat_bulletin.dart';
// import 'package:frontend/service/bulletin_service.dart';
// import 'package:gap/gap.dart';

// import '../../../../global/global_value.dart';
// import '../../../../helper/paginate_data.dart';
// import '../../../../model/bulletin_paie/bulletin_model.dart';
// import '../../../../widget/add_element_button.dart';
// import '../../../../widget/pagination.dart';
// import '../../../../widget/research_bar.dart';
// import '../../app_dialog_box.dart';
// import '../../error_page.dart';
// import 'current_bulletin_table.dart';

// class CurrentBulletinPage extends StatefulWidget {
//   const CurrentBulletinPage({super.key});

//   @override
//   State<CurrentBulletinPage> createState() => _CurrentBulletinState();
// }

// class _CurrentBulletinState extends State<CurrentBulletinPage> {
//   final TextEditingController _researchController = TextEditingController();
//   int currentPage = GlobalValue.currentPage;
//   String searchQuery = "";

//   Future<List<BulletinModel>> _loadServiceData() async {
   
//     return await BulletinService.getBulletins(etat: EtatBulletin.current);
   
//   }

//   void onClickGenerateButton() {
//     showResponsiveDialog(
//       context,
//       title: "Nouveau bulletin",
//       content: AddBulletinPage(refresh: () async {
//         setState(() {});
//       }),
//     );
//   }

//   void _onSearchChanged() {
//     setState(() {
//       searchQuery = _researchController.text;
//     });
//   }

//   @override
//   void initState() {
//     _researchController.addListener(_onSearchChanged);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ResearchBar(
//               hintText: "Rechercher par nom",
//               controller: _researchController,
//             ),
//             Container(
//               alignment: Alignment.centerRight,
//               child: AddElementButton(
//                 addElement: onClickGenerateButton,
//                 icon: Icons.add_outlined,
//                 label: "Ajouter un bulletin",
//               ),
//             ),
//           ],
//         ),
//         const Gap(4),
//         Expanded(
//           child: FutureBuilder<List<BulletinModel>>(
//             future: _loadServiceData(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return ErrorPage(
//                   message: snapshot.error.toString(),
//                   onPressed: () => setState(() {}),
//                 );
//               } else if (snapshot.hasData) {
//                 final data = snapshot.data!;
//                 if (data.isEmpty) {
//                   return NoDataPage(
//                     data: data,
//                     message: "Aucun bulletin de paie",
//                   );
//                 }
//                 final filteredData = data.where((item) {
//                   return item.personnel.nom.contains(
//                         searchQuery,
//                       ) ||
//                       item.personnel.prenom.contains(
//                         searchQuery,
//                       );
//                 }).toList();
//                 return Column(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         color: Theme.of(context).colorScheme.surface,
//                         child: CurrentBulletinTable(
//                           paginatedCurrentBulletintData: getPaginatedData(
//                             data: filteredData,
//                             currentPage: currentPage,
//                           ),
//                           refresh: () => setState(() {}),
//                         ),
//                       ),
//                     ),
//                     PaginationSpace(
//                       currentPage: currentPage,
//                       onPageChanged: (page) {
//                         setState(() {
//                           currentPage = page;
//                         });
//                       },
//                       filterDataCount: filteredData.length,
//                     ),
//                   ],
//                 );
//               }
//               return const Center(child: Text("État inattendu"));
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
