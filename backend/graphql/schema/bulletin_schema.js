const typeDef = `#graphql 
enum EtatBulletin{
    wait
       reject
       valid
       returne
}

type ValidateBulletin{
        validateStatus:EtatBulletin!
        validater:User!
        date:Float!
        commentaire: String!

    }
    input ValidateBulletinInput{
        validateStatus:EtatBulletin!
        validater:String!
        date:Float!
        commentaire: String!
    }


type BulletinPaie {
    _id: ID!
    etat: EtatBulletin!
    moyenPayement: MoyenPaiement
    debutPeriodePaie: Float!
    finPeriodePaie: Float!
    referencePaie: String
    banque: Banque!
    datePayement: Float
    dateEdition: Float!
    salarie: Salarie!
    validate: [ValidateBulletin]
    rubriques: [RubriqueOnBulletin!]!
}
`;

const query = `#graphql
    currentBulletinsPaie(perPage: Int, skip: Int, etat:EtatBulletin): [BulletinPaie]!
    archiveBulletinsPaie(perPage: Int, skip: Int, etat:EtatBulletin): [BulletinPaie]!
    currentValidateBulletin(perPage: Int, skip: Int): [BulletinPaie]!
    previousBulletinsPaie(salarieId: String!): BulletinPaie
    bulletinPaie(key: ID!): BulletinPaie!
`;

const mutation = `#graphql
    createBulletinPaie(
       moyenPayement: MoyenPaiementInput!
        debutPeriodePaie: Float!
        finPeriodePaie: Float!
        dateEdition: Float!
        banqueId: String!
        referencePaie: String!
        salarieId: String!
        rubriques: [RubriqueBulletinInput!]!
    ): String!

    getReadyBulletins(dateDebut: Float!, dateFin: Float!): [BulletinPaie]!
    
    updateBulletinPaie(
        key: ID!,
        moyenPayement: MoyenPaiementInput
        debutPeriodePaie: Float
        finPeriodePaie: Float
        dateEdition: Float
        banqueId: String
        referencePaie: String
        salarieId: String
        rubriques: [RubriqueBulletinInput]
    ): String!

     validerBulletin(
        key:ID!,
        validate: ValidateBulletinInput!
        datePayement: Float
    ):String!

    # deleteBulletinPaie(key: ID!): String!
`;

export default { typeDef, query, mutation };
