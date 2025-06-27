// import 'package:flutter/material.dart';
// import '../../../../model/bulletin_paie/retenue_model.dart';
// import '../../../../service/personnel_service.dart';
// import '../../../../widget/future_dropdown_field.dart';
// import '../../../../widget/rubrique_fields.dart';
// import '../../../integration/popop_status.dart';
// import '../../../integration/request_frot_behavior.dart';
// import '../../../../helper/date_helper.dart';
// import '../../../../model/bulletin_paie/bulletin_model.dart';
// import '../../../../model/personnel/personnel_model.dart';
// import '../../../../model/request_response.dart';
// import '../../../../service/bulletin_service.dart';
// import '../../../../widget/date_text_field.dart';
// import 'package:gap/gap.dart';

// import '../../../../widget/validate_button.dart';

// class EditBulletinPage extends StatefulWidget {
//   final VoidCallback refresh;
//   final BulletinModel bulletin;

//   const EditBulletinPage({
//     super.key,
//     required this.refresh,
//     required this.bulletin,
//   });

//   @override
//   State<EditBulletinPage> createState() => _EditBulletinPageState();
// }

// class _EditBulletinPageState extends State<EditBulletinPage> {
//   final List<Map<String, dynamic>> _retenusControllers = [];
//   final List<Map<String, dynamic>> _gainsControllers = [];
//   late TextEditingController _dateEditionController;

//   PersonnelModel? personnel;
//   DateTime? dateEdition;

//   @override
//   void initState() {
//     _retenusControllers.addAll(widget.bulletin.retenus
//         .where((e) => e.isAvance == null || e.isAvance == false)
//         .map((e) => {
//           'libelle': TextEditingController(text: e.libelle),
//           'montant': TextEditingController(text: e.montant.toString()),
//               'taux': TextEditingController(text: e.taux.toString())
//         }));
//     _gainsControllers.addAll(widget.bulletin.gains.map((e) => {
//           'libelle': TextEditingController(text: e.libelle),
//           'montant': TextEditingController(text: e.montant.toString()),
//           'taux': TextEditingController(text: e.taux.toString())
//         }));


//     _dateEditionController = TextEditingController(
//       text: getStringDate(
//         time: DateTime.parse(widget.bulletin.dateEdition.toIso8601String()),
//       ),
//     );

//     personnel = widget.bulletin.personnel;
//     dateEdition = DateTime.parse(widget.bulletin.dateEdition.toIso8601String());

//     super.initState();
//   }

//   @override
//   void dispose() {
  
//     _dateEditionController.dispose();
//     super.dispose();
//   }

// Future<List<PersonnelModel>> fetchItems() async {
//     return await PersonnelService.getUnarchivedPersonnels();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           FutureCustomDropDownField(
//             label: "Personnel",
//             selectedItem: personnel,
//             fetchItems: fetchItems,
//             onChanged: (value) {
//               setState(() {
//                 personnel = value;
//               });
//             },
//             itemsAsString: (personnel) =>
//                 "${personnel.nom} ${personnel.prenom}",
//           ),
//           DateField(
//             onCompleteDate: (date) {
//               if (date != null) {
//                 dateEdition = date;
//                 _dateEditionController.text = getStringDate(time: dateEdition!);
//               }
//             },
//             label: "Date d'édition",
//             dateController: _dateEditionController,
//           ),
//           RubriquesFields(
//             controllers: _gainsControllers,
//             required: true,
//             rubriqueName: "Gain",
//           ),
//           RubriquesFields(
//             controllers: _retenusControllers,
//             rubriqueName: "Retenu",
//           ),
//           const Gap(16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Align(
//               alignment: Alignment.bottomRight,
//               child: ValidateButton(
//                 onPressed: () async {
//                   await _updateBulletin();
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   _updateBulletin() async {
//     bool isPersonnelModified = personnel?.id != widget.bulletin.personnel.id;
//     bool isDateModified = dateEdition != widget.bulletin.dateEdition;
//     List<RubriqueModel> updatedGains = _gainsControllers
//         .where((e) {
//           final originalGain = widget.bulletin.gains.firstWhere(
//             (gain) => gain.libelle == e["libelle"].text,
//             orElse: () => RubriqueModel(
//               libelle: '',
//               montant: 0,
//               taux: 0,
//             ),
//           );
//           return originalGain.montant != double.parse(e["montant"].text);
//         })
//         .map((e) => RubriqueModel(
//               libelle: e["libelle"].text,
//               montant: double.parse(e["montant"].text),
//               taux: double.parse(e["montant"].text),
//             ))
//         .toList();

//     List<RubriqueModel> deletedGains = widget.bulletin.gains
//         .where((gain) =>
//             !_gainsControllers.any((e) => e["libelle"].text == gain.libelle))
//         .toList();

//     List<RubriqueModel> updatedRetenus = _retenusControllers
//         .where((e) {
//           final originalRetenu = widget.bulletin.retenus.firstWhere(
//             (retenu) => retenu.libelle == e["libelle"].text,
//             orElse: () => RubriqueModel(
//               libelle: '',
//               montant: 0,
//               taux: 0,
//             ),
//       );
//           return originalRetenu.montant != double.parse(e["montant"].text);
//         })
//         .map((e) => RubriqueModel(
//               libelle: e["libelle"].text,
//               montant: double.parse(e["montant"].text),
//               taux: double.parse(e["taux"].text),
//             ))
//         .toList();

// List<RubriqueModel> deletedRetenus = widget.bulletin.retenus
//         .where((retenu) => !_retenusControllers
//             .any((e) => e["libelle"].text == retenu.libelle))
//         .toList();

//     if (!isPersonnelModified &&
//         !isDateModified &&
//         updatedGains.isEmpty &&
//         deletedGains.isEmpty &&
//         updatedRetenus.isEmpty &&
//         deletedRetenus.isEmpty) {
//       MutationRequestContextualBehavior.showCustomInformationPopUp(
//         message: "Aucune modification détectée.",
//       );
//       return;
//     }
    
//       RequestResponse result = await BulletinService.updateBulletin(
//         key: widget.bulletin.id,
//       personnelId: isPersonnelModified ? personnel!.id : null,
//       retenus: updatedRetenus,
//       gains: updatedGains,
//       dateEdition: isDateModified ? dateEdition : null,
//       );

//       if (result.status == PopupStatus.success) {
//       MutationRequestContextualBehavior.closePopup();
//         MutationRequestContextualBehavior.showPopup(
//           status: result.status,
//           customMessage: "Bulletin modifié avec succès",
//         );
//       widget.refresh();
//       } else {
//         MutationRequestContextualBehavior.showPopup(
//           status: result.status,
//           customMessage: result.message,
//         );
//       }
    
//   }
// }
