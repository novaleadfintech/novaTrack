// la fonction pour voir si la categorie choisie a été confihurée avant son utiliisation mais inutile à cette version

/*Future<List<RubriqueBulletin>> fetchRubriqueItems() async {
    if (bulletinCategorie == null) {
      throw ("Veuillez choisir la catégorie de paie.");
    }

    final List<RubriqueOnBulletinModel> rubriquePaieResponse =
        await RubriqueCategorieConfService
            .getBulletinRubriquesByBulletinCategorie(
      bulletinCategorie: bulletinCategorie!,
    );

    return rubriquePaieResponse
        .where(
          (cat) => cat.rubrique.nature == NatureRubrique.constant,
        )
        .map((cat) => cat.rubrique)
        .toList();
  }*/
