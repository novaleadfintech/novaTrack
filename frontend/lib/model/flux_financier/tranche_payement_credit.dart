class TranchePayementModel {
  final double montantPaye;
  final DateTime datePayement ;

  TranchePayementModel({
     required this.montantPaye,
    required this.datePayement,
  });

  factory TranchePayementModel.fromJson(Map<String, dynamic> json) {
    return TranchePayementModel(
       montantPaye: json["montantPaye"],
      datePayement: DateTime.fromMillisecondsSinceEpoch(json['datePayement']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "montantPaye": montantPaye,
      "datePayement": datePayement.millisecondsSinceEpoch,
    };
  }
}
