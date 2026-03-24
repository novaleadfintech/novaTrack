const typeDef = `#graphql
type Operateur{
    _key:ID!
    libelle:String!
}
input OperateurInput{
    _key:ID!
    libelle:String!
}
`;

const query = `#graphql
    operateurs(perPage:Int, skip:Int):[Operateur]!
    operateur(key:ID!):Operateur!  
`;

const mutation = `#graphql
    createOperateur(libelle:String!):String!
    updateOperateur(key:ID!, libelle:String):String!
    deleteOperateur(key:ID!):String!
`;

export default { typeDef, query, mutation };
