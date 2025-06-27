class ModuleModel {
  final String? id;
  final String name;
  final String alias;

  ModuleModel({
    this.id,
    required this.name,
    required this.alias,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['_id'],
      name: json['name'],
      alias: json['alias'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'alias': alias,
    };
  }
}
