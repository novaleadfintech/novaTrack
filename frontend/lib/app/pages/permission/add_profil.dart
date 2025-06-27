

// import 'package:flutter/material.dart';
// import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
// import '../../../service/role_service.dart';
// import '../../../widget/simple_text_field.dart';
// import '../../../widget/validate_button.dart';
// import 'package:gap/gap.dart';

// import '../../integration/popop_status.dart';
// import '../../integration/request_frot_behavior.dart';

// class AddProfil extends StatefulWidget {
//   const AddProfil({super.key});

//   @override
//   State<AddProfil> createState() => _AddProfilState();
// }

// class _AddProfilState extends State<AddProfil> {
//   final _profilController = TextEditingController();
//   late SimpleFontelicoProgressDialog _dialog;

//   @override
//   void initState() {
//     super.initState();
//     _dialog = SimpleFontelicoProgressDialog(context: context);
//   }

//   addProfil() async {
//     String? errMessage;
//     if (_profilController.text.isEmpty) {
//       errMessage = "Veuillez remplir tous les champs marqués.";
//     }

//     if (errMessage != null) {
//       MutationRequestContextualBehavior.showCustomInformationPopUp(
//         message: errMessage,
//       );
//       return;
//     }

//     _dialog.show(
//       message: "",
//       type: SimpleFontelicoProgressDialogType.phoenix,
//       backgroundColor: Colors.transparent,
//     );

//     var result = await RoleService.createRole(
//       libelle: _profilController.text,
//     );

//     _dialog.hide();

//     if (result.status == PopupStatus.success) {
//       MutationRequestContextualBehavior.closePopup();
//       MutationRequestContextualBehavior.showPopup(
//         status: PopupStatus.success,
//         customMessage: "Role crée avec succès",
//       );
//     } else {
//       MutationRequestContextualBehavior.showPopup(
//         status: result.status,
//         customMessage: result.message,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SimpleTextField(label: "Libelle", textController: _profilController),
//         const Gap(8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Align(
//             alignment: Alignment.bottomRight,
//             child: ValidateButton(
//               onPressed: () {
//                 addProfil();
//               },
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }
