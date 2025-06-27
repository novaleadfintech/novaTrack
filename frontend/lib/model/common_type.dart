enum Sexe {
  F('Féminin'),
  M('Masculin');

  final String label;
  const Sexe(this.label);
}

String sexeToString(Sexe sexe) {
  return sexe.toString().split('.').last;
}

Sexe sexeFromString(String sexe) {
  return Sexe.values.firstWhere((e) => e.toString().split('.').last == sexe);
}
enum Civilite {
  madam('Mme'),
  miss('Mlle'),
  sir('M.');

  final String label;
  const Civilite(this.label);
}

String civiliteToString(Civilite civilite) {
  return civilite.toString().split('.').last;
}

Civilite civiliteFromString(String civilite) {
  return Civilite.values
      .firstWhere((e) => e.toString().split('.').last == civilite);
}

enum SituationMatrimoniale {
  single("Célibataire"),
  married("Marié"),
  divorced("Divorcé"),
  widowed("Veuf");

  final String label;
  const SituationMatrimoniale(this.label);
}

String situationMatrimonialeToString(SituationMatrimoniale situation) {
  return situation.toString().split('.').last;
}

SituationMatrimoniale situationMatrimonialeFromString(String situation) {
  return SituationMatrimoniale.values
      .firstWhere((e) => e.toString().split('.').last == situation);
}

class File {
  final String filename;
  final String mimetype;
  final String url;
  final String content;

  File({
    required this.filename,
    required this.mimetype,
    required this.url,
    required this.content,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      filename: json["content"],
      mimetype: json["mimetype"],
      url: json["url"],
      content: json["content"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "mimetype": mimetype,
      "url": url,
      "filename": filename,
    };
  }
}
