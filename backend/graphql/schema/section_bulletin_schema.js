const typeDef = `#graphql
type SectionBulletin{
    _key:ID!
    section:String!
}

input SectionBulletinInput {
    _key:String!
    section:String!
}
`;

const query = `#graphql
    sectionsBulletin(perPage:Int, skip:Int,):[SectionBulletin]!
    sectionBulletin(key:ID!):SectionBulletin!
`;

const mutation = `#graphql
    createSectionBulletin(section:String!,):String!
    updateSectionBulletin(key:ID!, section:String, ):String!
    deleteSectionBulletin(key:ID!):String!
`;

export default { typeDef, query, mutation };
