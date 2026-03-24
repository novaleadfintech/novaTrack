const typeDef = `#graphql
type Poste{
    _key:ID!
    libelle:String!
}
input PosteInput{
    _key:ID!
    libelle:String!
}
`;

const query = `#graphql
    postes(perPage:Int, skip:Int):[Poste]!
    poste(key:ID!):Poste!  
`;

const mutation = `#graphql
    createPoste(libelle:String!):String!
    updatePoste(key:ID!, libelle:String):String!
    deletePoste(key:ID!):String!
`;

export default { typeDef, query, mutation };
