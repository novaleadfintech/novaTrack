const typeDef = `#graphql
    type Salarie{
        _keyy:ID!
        personnel: Personnel!
        bulletinCategorie: BulletinCategorie
        classe: Classe
        numeroMatricule: String
        echelon: Echelon
        grillepaieCategorie: paieCategorieGrille
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
            personnelKey: String!
            bulletinCategorieKey: String!
            periodPaie: Float
            # paieManner: PaieManner!
            numeroMatricule: String!
            classeKey: String!
            paieClause: PaieClause!
            operateur: OperateurInput!
            numeroCompte: String
            moyenPaiement: MoyenPaiementInput!
            echelonKey: String!
            grillepaieCategorieKey: String!
        ):String!,

        updateSalarie(
            key:ID!
            personnelKey: String
            bulletinCategorieKey: String
            periodPaie: Float
            numeroMatricule: String
            classeKey: String
            operateur: OperateurInput
            numeroCompte: String
            echelonKey: String
            grillepaieCategorieKey: String
            moyenPaiement: MoyenPaiementInput
            paieClause: PaieClause
        ):String!,
`;

export default { typeDef, query, mutation };