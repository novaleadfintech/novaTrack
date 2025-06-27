const typeDef = `#graphql
type CategoriePaie{
    _id:ID!
    categoriePaie:String!
}
`;

const query = `#graphql
    categoriesPaie(perPage:Int, skip:Int):[CategoriePaie]!
    categoriePaie(key:ID!):CategoriePaie!
`;

const mutation = `#graphql
    createCategoriePaie(categoriePaie:String!):String!
    updateCategoriePaie(key:ID!, categoriePaie:String):String!
    deleteCategoriePaie(key:ID!):String!
`;

export default { typeDef, query, mutation };
