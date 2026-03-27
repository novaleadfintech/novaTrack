const typeDef = `#graphql

enum RoleAuthorization {
    accepted
    wait
    refused
}
#Definition du type role
    type Role{
        _key: ID!
        libelle: String!
        permissions: [Permission]!
    }

    type UserRole{
        _key: ID!
        roleAuthorization: RoleAuthorization
        role: Role!
        authorizer: User
        authorizeTime: Float
        createBy: User
        timeStamp: Float
    }
`;

const query = `#graphql
    roles: [Role]!
    role(key: ID!): Role!
    roleByUser(userKey: String!): [Role]!
`;

const mutation = `#graphql
    createRole(libelle: String!): String!
    attribuerPermissionRole(rolekey: ID!, permissionKey: String!): String!
    retirerPermissionRole(rolekey: ID!, permissionKey: String!): String!
    updateRole(key: ID!, libelle: String): String!
    deleteRole(key: ID!): String!
 `;
export default { typeDef, query, mutation };