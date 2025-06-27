const typeDef = `#graphql
    type LigneFacture{
        _id:ID!
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
        serviceId:String!
        fraisDivers: [FraisDiversInput]
    }
`;
const query = `#graphql
    ligneFactureByFacture(factureId:String!): [LigneFacture]!  
    ligneFacture(key:ID!): LigneFacture!    
`;

const mutation = `#graphql
    updateLigneFacture(
        key: ID!
        designation: String
        quantite: Int
        serviceId: String
        prixSupplementaire: Float,
        unit: String
        dureeLivraison: Float
        remise: Float
        fraisDivers: [FraisDiversInput]
    ):String!
    
    deleteLigneFacture(key:ID!):String!
    # deleteAllByFacture(factureId:String!):String!
`;

export default { typeDef, query, mutation };
