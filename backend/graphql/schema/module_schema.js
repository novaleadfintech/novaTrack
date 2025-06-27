const typeDef = `#graphql
    type Module{
        _id: ID!
        name: String!
        alias: String!
        # permissions: [Permission]!
    }
`;

const query = `#graphql
    Modules: [Module]!
    # Module(key: ID!): Module!
    # ModuleByUser(userId: String!): [Module]!
`;

export default { typeDef, query };
