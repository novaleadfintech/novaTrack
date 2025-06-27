const typeDef = `#graphql
#Definition du type role
    type Role{
        _id: ID!
        libelle: String!
        permissions: [Permission]!
    }
`;

const query = `#graphql
    roles: [Role]!
    role(key: ID!): Role!
    roleByUser(userId: String!): [Role]!
`;

const mutation = `#graphql
    createRole(libelle: String!): String!
    attribuerPermissionRole(rolekey: ID!, permissionId: String!): String!
    retirerPermissionRole(rolekey: ID!, permissionId: String!): String!
    updateRole(key: ID!, libelle: String): String!
    deleteRole(key: ID!): String!
 `;
export default { typeDef, query, mutation };
