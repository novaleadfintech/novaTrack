const typeDef = `#graphql
    type LigneFacture{
        _key:ID!
        designation:String!
        unit: String!
        quantite:Int!
        dureeLivraison:Float
        montant:Float!
        prixSupplementaire: Float,
        remise:Float
        service:Service!
        fraisDivers: [FraisDivers]
    }

    input LigneFactureInput{
        designation:String!
        unit: String!
        quantite:Int
        prixSupplementaire: Float,
        dureeLivraison:Float
        remise:Float
        serviceKey:String!
        fraisDivers: [FraisDiversInput]
    }
`;
const query = `#graphql
    ligneFactureByFacture(factureKey:String!): [LigneFacture]!  
    ligneFacture(key:ID!): LigneFacture!    
`;

const mutation = `#graphql
    updateLigneFacture(
        key: ID!
        designation: String
        quantite: Int
        serviceKey: String
        prixSupplementaire: Float,
        unit: String
        dureeLivraison: Float
        remise: Float
        fraisDivers: [FraisDiversInput]
    ):String!
    
    deleteLigneFacture(key:ID!):String!
    # deleteAllByFacture(factureKey:String!):String!
`;

export default { typeDef, query, mutation };