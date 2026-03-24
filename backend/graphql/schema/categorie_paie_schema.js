const typeDef = `#graphql
type paieCategorie{
    _key:ID!
    paieCategorie:String!
}
`;

const query = `#graphql
    categoriesPaie(perPage:Int, skip:Int):[paieCategorie]!
    paieCategorie(key:ID!):paieCategorie!
`;

const mutation = `#graphql
    createpaieCategorie(paieCategorie:String!):String!
    updatepaieCategorie(key:ID!, paieCategorie:String):String!
    deletepaieCategorie(key:ID!):String!
`;

export default { typeDef, query, mutation };