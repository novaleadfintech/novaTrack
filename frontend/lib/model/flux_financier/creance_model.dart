
import '../client/client_model.dart';
import '../facturation/facture_model.dart';

class CreanceModel {
  ClientModel? client;
  List<FactureModel>? factures;
  final double montantRestant;
  static dynamic creanceModelErr;

  CreanceModel({
    this.client,
    this.factures,
    required this.montantRestant,
  });

  factory CreanceModel.fromJson(Map<String, dynamic> json) {
    return CreanceModel(
      client:
          json['client'] != null ? ClientModel.fromJson(json['client']) : null,        
      factures: json['factures'] == null
          ? []
          : (json['factures'] as List)
              .map((e) => FactureModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      montantRestant: (json["montantRestant"] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client': client?.toJson(),
      'facture': factures?.map((e) => e.toJson()).toList(),
      'montantRestant': montantRestant,
    };
  }
}
