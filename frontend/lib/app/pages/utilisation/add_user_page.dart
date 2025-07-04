import 'package:flutter/material.dart';
import 'package:frontend/model/habilitation/user_model.dart';
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

class AddUserPage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddUserPage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  late SimpleFontelicoProgressDialog _dialog;
  PersonnelModel? personnel;
  RoleModel? role;
  String? currentPersonnelId;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    UserModel? user = await AuthService().decodeToken();
    setState(() {
      currentPersonnelId = user!.personnel!.id;
      currentUserId = user.id;
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
        createBy: currentUserId!,
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
    return await RoleService.getRoles();
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
      assignNewRoleToPersonnel(
        personnel: personnel!,
        role: role!,
      );
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.information,
        customMessage: "Veuillez sélectionner un rôle, SVP.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureCustomDropDownField<PersonnelModel>(
            label: "Personnel",
            selectedItem: personnel,
            fetchItems: fetchPersonnelItems,
            onChanged: (PersonnelModel? value) {
              setState(() {
                personnel = value;
              });
            },
            itemsAsString: (p) => "${p.nom} ${p.prenom}",
          ),
          FutureCustomDropDownField<RoleModel>(
            label: "Rôle",
            selectedItem: role,
            fetchItems: fetchRoleItems,
            canClose: false,
            onChanged: (RoleModel? value) {
              setState(() {
                role = value;
              });
            },
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
