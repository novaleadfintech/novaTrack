const typeDef = `#graphql
type Echelon{
    _id:ID!
    libelle:String!
}
`;

const query = `#graphql
    ehelons(perPage:Int, skip:Int):[Echelon]!
    echelon(key:ID!):Echelon!
`;

const mutation = `#graphql
    createEchelon(libelle:String!):String!
    updateEchelon(key:ID!, libelle:String):String!
    deleteEchelon(key:ID!):String!
`;

export default { typeDef, query, mutation };
