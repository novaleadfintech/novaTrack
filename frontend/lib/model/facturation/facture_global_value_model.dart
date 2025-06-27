import '../client/client_model.dart';

class ClientFactureGlobaLValueModel {
  final ClientModel client;
  final int? nbreJrMaxPenalty;

  ClientFactureGlobaLValueModel({
    required this.client,
    required this.nbreJrMaxPenalty,
  });
  factory ClientFactureGlobaLValueModel.fromJson(Map<String, dynamic> json) {
     return ClientFactureGlobaLValueModel(
      client: ClientModel.fromJson(json["client"]),
      nbreJrMaxPenalty: (json["nbreJrMaxPenalty"]) != null
          ? int.parse(json["nbreJrMaxPenalty"].toString())
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "client": client.toJson(),
      "nbreJrMaxPenalty": nbreJrMaxPenalty,
    };
  }
}
