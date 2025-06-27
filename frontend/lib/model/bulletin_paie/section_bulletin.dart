class SectionBulletin {
  final String id;
  final String section;

  SectionBulletin({
    required this.id,
    required this.section,
  });

  factory SectionBulletin.fromJson(Map<String, dynamic> json) {
    return SectionBulletin(
      id: json['_id'],
      section: json['section'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'section': section,
    };
  }
}
