const typeDef = `#graphql
    type LigneProforma{
        _id:ID!
        designation:String!
        unit: String!
        quantite:Int!
        dureeLivraison:Float
        prixSupplementaire: Float,
        montant:Float!
        remise:Float
        service:Service!
        fraisDivers: [FraisDivers]
    }

    input LigneProformaInput{
        designation:String!
        unit: String!
        quantite:Int
        prixSupplementaire: Float,
        dureeLivraison:Float
        # remise:Float
        serviceId:String!
        fraisDivers: [FraisDiversInput]
    }
`;
const query = `#graphql
    ligneProformaByProforma(proformaId:String!): [LigneProforma]!  
    ligneProforma(key:ID!): LigneProforma!    
`;

const mutation = `#graphql
    updateLigneProforma(
        key: ID!
        designation: String
        quantite: Int
        serviceId: String
        unit: String
        prixSupplementaire: Float,
        dureeLivraison:Float
        # remise: Float
        fraisDivers: [FraisDiversInput]
    ):String!
    
    deleteLigneProforma(key:ID!):String!
    # deleteAllByProforma(proformaId:String!):String!
`;

export default { typeDef, query, mutation };
