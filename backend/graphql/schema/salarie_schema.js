const typeDef = `#graphql
    type Salarie{
        _id:ID!
        personnel: Personnel!
        categoriePaie: CategoriePaie!
        classe: Classe
        numeroMatricule: String
        echelon: Echelon
        grilleCategoriePaie: CategoriePaieGrille
        dateEnregistrement: Float!
        periodPaie: Float
        paieManner: PaieManner
        fullCount:Int
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
`;

const query = `#graphql
        salaries(skip:Int, perPage:Int,):[Salarie]!
        salarie(key:ID!):Salarie!
    `;

const mutation = `#graphql
        createSalarie(
            personnelId: String!
            categoriePaieId: String!
            periodPaie: Float
            paieManner: PaieManner!
            numeroMatricule: String!
            classeId: String!
            echelonId: String!
            grilleCategoriePaieId: String!
        ):String!,

        updateSalarie(
            key:ID!
            personnelId: String
            categoriePaieId: String
            periodPaie: Float
            paieManner: PaieManner
        ):String!,
`;

export default { typeDef, query, mutation };
