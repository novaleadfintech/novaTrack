const typeDef = `#graphql
#Definition du type permission
    type Permission{
        _key: ID!
        libelle: String!
        alias: String!
        isChecked: Boolean
        module: Module
    }

    type ModulePermission{
        permissions: [Permission]!
        module: Module!
    }
`;

const query = `#graphql
    permissions: [ModulePermission]!
    permission(key: ID!): Permission!
    permissionByRole(roleKey: String!): [ModulePermission]!
    permissionByModule(moduleKey: String!): [Permission]!
`;

const mutation = `#graphql
     createPermission(libelle: String!, moduleKey: String): String!
     updatePermission(key: ID!, libelle: String): String!
    deletePermission(key: ID!): String!
`;

export default { typeDef, query, mutation };