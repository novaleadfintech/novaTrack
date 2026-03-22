const typeDef = `#graphql
type CategorieBulletin{
    _id:ID!
    categorieBulletin:String!
    paieClause: PaieClause!
}
`;

const query = `#graphql
    categoriesBulletin(perPage:Int, skip:Int):[CategorieBulletin]!
    categorieBulletin(key:ID!):CategorieBulletin!
`;

const mutation = `#graphql
    createCategorieBulletin(categorieBulletin:String!, paieClause: PaieClause!):String!
    updateCategorieBulletin(key:ID!, categorieBulletin:String, paieClause: PaieClause):String!
    deleteCategorieBulletin(key:ID!):String!
`;

export default { typeDef, query, mutation };
