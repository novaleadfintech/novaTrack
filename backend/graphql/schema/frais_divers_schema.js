const typeDef = `#graphql
    type FraisDivers{
        libelle:String!
        montant:Float!
        tva:Boolean!
    }

    input FraisDiversInput{
        libelle:String!
        montant:Float!
        tva:Boolean!
    }
`;

export default { typeDef };
