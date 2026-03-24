class SectionBulletin {
  final String key;
  final String section;

  SectionBulletin({
    required this.key,
    required this.section,
  });

  factory SectionBulletin.fromJson(Map<String, dynamic> json) {
    return SectionBulletin(
      key: json['_key'],
      section: json['section'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_key': key,
      'section': section,
    };
  }
}
