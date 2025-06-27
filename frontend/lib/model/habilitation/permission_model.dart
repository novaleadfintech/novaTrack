// permission.dart

import 'module_model.dart';

class PermissionModel {
  final String id;
  final String libelle;
  final String alias;
  final bool? isChecked;
  final ModuleModel? module;

  PermissionModel({
    required this.id,
    required this.libelle,
    required this.alias,
    this.isChecked,
    this.module,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['_id'],
      libelle: json['libelle'],
      alias: json['alias'],
      isChecked: json['isChecked'],
      module:
          json['module'] != null ? ModuleModel.fromJson(json['module']) : null,
    );
  }

  set isChecked(bool? isChecked) {}

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'libelle': libelle,
      'alias': alias,
      'isChecked': isChecked,
      'moudule': module?.toJson(),
    };
  }
}
