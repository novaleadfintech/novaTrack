import 'package:flutter/material.dart';
import 'package:frontend/model/habilitation/user_model.dart';
import 'package:frontend/widget/drop_down_text_field.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/personnel/personnel_model.dart';
import "../../../model/habilitation/role_model.dart";
import '../../../service/personnel_service.dart';
import '../../../service/role_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/common_type.dart';
import '../../../model/request_response.dart';
import '../../../service/user_service.dart';
import '../../../widget/confirmation_dialog_box.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class EditUserPage extends StatefulWidget {
  final UserModel user;
  final Future<void> Function() refresh;
  const EditUserPage({
    super.key,
    required this.refresh,
    required this.user,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late SimpleFontelicoProgressDialog _dialog;
  PersonnelModel? personnel;
  RoleModel? role;
  String? currentPersonnelId;

  @override
  void initState() {
    super.initState();
    personnel = widget.user.personnel;
    role = widget.user.roles!.first;
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    UserModel? user = await AuthService().decodeToken();
    setState(() {
      currentPersonnelId = user!.personnel!.id;
    });
  }

  Future<void> assignNewRoleToPersonnel({
    required PersonnelModel personnel,
    required RoleModel role,
  }) async {
    String determinant = personnel.sexe == Sexe.F ? "Mme" : "M.";
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Êtes-vous sûr de vouloir définir $determinant ${personnel.prenom} ${personnel.nom} comme ${role.libelle}?",
    );

    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await UserService.assignRoleToPersonnel(
        personnelId: personnel.id,
        roleId: role.id!,
      );
      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage:
              "$determinant ${personnel.prenom} ${personnel.nom} a été défini comme ${role.libelle}",
        );
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    }
  }

  Future<List<RoleModel>> fetchRoleItems() async {
    return await RoleService.getRole();
  }

  Future<List<PersonnelModel>> fetchPersonnelItems() async {
    List<PersonnelModel> personnels =
        await PersonnelService.getUnarchivedPersonnels();

    // Exclure l'utilisateur connecté de la liste
    if (currentPersonnelId != null) {
      personnels.removeWhere((p) => p.id == currentPersonnelId);
    }

    return personnels;
  }

  onvalidate() {
    if (personnel != null && role != null) {
      if (role!.id == widget.user.roles!.first.id) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.information,
          customMessage: "Aucune modification n'a été faite.",
        );
        return;
      }
      assignNewRoleToPersonnel(
        personnel: personnel!,
        role: role!,
      );
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage: "Veuillez sélectionner un personnel et un rôle.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropDownField<PersonnelModel>(
            items: [personnel!],
            onChanged: (PersonnelModel? value) {
              setState(() {
                personnel = value;
              });
            },
            label: "Personnel",
            canClose: false,
            selectedItem: personnel,
            itemsAsString: (p0) => p0.toStringify(),
          ),
          FutureCustomDropDownField<RoleModel>(
            label: "Rôle",
            selectedItem: role,
            fetchItems: fetchRoleItems,
            onChanged: (RoleModel? value) {
              setState(() {
                role = value;
              });
            },
            canClose: false,
            itemsAsString: (r) => r.libelle,
          ),
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ValidateButton(
                onPressed: () {
                  onvalidate();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
