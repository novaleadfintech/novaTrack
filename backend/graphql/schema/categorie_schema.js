const typeDef = `#graphql
type Categorie{
    _id:ID!
    libelle:String!
}
`;

const query = `#graphql
    categories(perPage:Int, skip:Int):[Categorie]!
    categorie(key:ID!):Categorie!
`;

const mutation = `#graphql
    createCategorie(libelle:String!):String!
    updateCategorie(key:ID!, libelle:String):String!
    deleteCateforie(key:ID!):String!
`;

export default {typeDef, query, mutation};