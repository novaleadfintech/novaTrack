import 'package:frontend/model/habilitation/user_model.dart';

class CommentModel {
  final String message;
  final DateTime date;
  final UserModel? editer;

  CommentModel({
    required this.message,
    required this.date,
    this.editer,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      message: json["message"],
      date: DateTime.fromMillisecondsSinceEpoch(json["date"]),
      editer: json["editer"] != null
          ? UserModel.fromJson(json["editer"] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "date": date.millisecondsSinceEpoch,
      "editer": editer?.toJson(),
    };
  }
}
