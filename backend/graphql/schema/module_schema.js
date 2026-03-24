const typeDef = `#graphql
    type Module{
        _key: ID!
        name: String!
        alias: String!
        # permissions: [Permission]!
    }
`;

const query = `#graphql
    Modules: [Module]!
    # Module(key: ID!): Module!
    # ModuleByUser(userKey: String!): [Module]!
`;

export default { typeDef, query };