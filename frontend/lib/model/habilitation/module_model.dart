class ModuleModel {
  final String? key;
  final String name;
  final String alias;

  ModuleModel({
    this.key,
    required this.name,
    required this.alias,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      key: json['_key'],
      name: json['name'],
      alias: json['alias'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_key': key,
      'name': name,
      'alias': alias,
    };
  }
}
