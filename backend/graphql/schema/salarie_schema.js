const typeDef = `#graphql
    type Salarie{
        _id:ID!
        personnel: Personnel!
        categorieBulletin: CategorieBulletin
        classe: Classe
        numeroMatricule: String
        echelon: Echelon
        grilleCategoriePaie: CategoriePaieGrille
        dateEnregistrement: Float!
        operateur: Operateur
        numeroCompte: String
        periodPaie: Float
        moyenPaiement: MoyenPaiement
        # paieManner: PaieManner
        paieClause: PaieClause!
        fullCount: Int
    }

    enum TypePaie{
        forfait
        taux
    }

    enum PaieManner{
        finMois
        termeEchu
        finPeriod
    }

    enum PaieClause{
        forfaitMensuel
        Journalier
        horaire
        grille
    }
`;

const query = `#graphql
        salaries(skip:Int, perPage:Int,):[Salarie]!
        salarie(key:ID!):Salarie!
    `;

const mutation = `#graphql
        createSalarie(
            personnelId: String!
            categorieBulletinId: String!
            periodPaie: Float
            # paieManner: PaieManner!
            numeroMatricule: String!
            classeId: String!
            paieClause: PaieClause!
            operateur: OperateurInput!
            numeroCompte: String
            moyenPaiement: MoyenPaiementInput!
            echelonId: String!
            grilleCategoriePaieId: String!
        ):String!,

        updateSalarie(
            key:ID!
            personnelId: String
            categorieBulletinId: String
            periodPaie: Float
            numeroMatricule: String
            classeId: String
            operateur: OperateurInput
            numeroCompte: String
            echelonId: String
            grilleCategoriePaieId: String
            moyenPaiement: MoyenPaiementInput
            paieClause: PaieClause
        ):String!,
`;

export default { typeDef, query, mutation };