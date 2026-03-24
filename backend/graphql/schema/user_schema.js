const typeDef = `#graphql
    type User{
        _key:ID!
        login:String!
        password:String!
        personnel:Personnel! 
        roles:[UserRole]!  
        canLogin:Boolean!
        _token:String
        isTheFirstConnection:Boolean
        dateEnregistrement:Float!
    }
`;
const query = `#graphql
    users:[User]!
    user(key:ID!):User!
`;

const mutation = `#graphql
    seConnecter(login:String!, password:String!):User!
    seDeconnecter(key:ID!):String!
    attribuerRolePersonnel(personnelKey:String!, roleKey:String!, createBy:String!):String!
    attribuerRoleUser(key:String!, roleKey:String!):String!
    retirerRoleUser(key:String!, roleKey:String!):String!
    updateLoginData(key:ID!, login:String, password:String!, oldPassword:String!):String!
    resetLoginParameter(key:ID!):String!
    handleRoleEditing(userRoleKey:ID!, roleAuthorization: RoleAuthorization!, authorizer: String!):String!
    access(key:ID!, canLogin: Boolean!):String!
`;

export default { typeDef, query, mutation };