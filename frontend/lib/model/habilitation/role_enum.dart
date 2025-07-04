enum RoleAuthorization {
  accepted("Accepté"),
  wait("En attente"),
  refused("Refusé");

  final String label;

  const RoleAuthorization(this.label);

  static String roleAuthorizationToString(RoleAuthorization roleAuthorization) {
    return roleAuthorization.toString().split('.').last;
  }

  static RoleAuthorization roleAuthorizationFromString(
      String roleAuthorization) {
    return RoleAuthorization.values
        .firstWhere((e) => e.toString().split('.').last == roleAuthorization);
  }
}
