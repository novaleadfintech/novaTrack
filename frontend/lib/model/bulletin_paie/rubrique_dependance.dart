import 'package:frontend/model/bulletin_paie/rubrique.dart';

class RubriqueDependance {
  final RubriqueBulletin rubrique;
  final RubriqueBulletin parent;

  RubriqueDependance({
    required this.rubrique,
    required this.parent,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RubriqueDependance &&
          rubrique.key == other.rubrique.key &&
          parent.key == other.parent.key;

  @override
  int get hashCode => rubrique.key.hashCode ^ parent.key.hashCode;
}
