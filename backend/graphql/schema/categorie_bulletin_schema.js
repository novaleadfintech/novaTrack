const typeDef = `#graphql
type BulletinCategorie{
    _key:ID!
    bulletinCategorie:String!
    paieClause: PaieClause!
}
`;

const query = `#graphql
    bulletinCategories(perPage:Int, skip:Int):[BulletinCategorie]!
    bulletinCategorie(key:ID!):BulletinCategorie!
`;

const mutation = `#graphql
    createBulletinCategorie(bulletinCategorie:String!, paieClause: PaieClause!):String!
    updateBulletinCategorie(key:ID!, bulletinCategorie:String, paieClause: PaieClause):String!
    deleteBulletinCategorie(key:ID!):String!
`;

export default { typeDef, query, mutation };