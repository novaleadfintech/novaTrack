const typeDef = `#graphql
type partnerCategorie{
    _key:ID!
    libelle:String!
}
`;

const query = `#graphql
    partnerCategories(perPage:Int, skip:Int):[partnerCategorie]!
    partnerCategorie(key:ID!):partnerCategorie!
`;

const mutation = `#graphql
    createPartnerCategorie(libelle:String!):String!
    updatePartnerCategorie(key:ID!, libelle:String):String!
    deleteCateforie(key:ID!):String!
`;

export default { typeDef, query, mutation };