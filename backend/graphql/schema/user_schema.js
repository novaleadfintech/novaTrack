const typeDef = `#graphql
    type User{
        _id:ID!
        login:String!
        password:String!
        personnel:Personnel! 
        roles:[Role]!  
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
    attribuerRolePersonnel(personnelId:String!, roleId:String!):String!
    attribuerRoleUser(key:String!, roleId:String!):String!
    retirerRoleUser(key:String!, roleId:String!):String!
    updateLoginData(key:ID!, login:String, password:String!, oldPassword:String!):String!
    resetLoginParameter(key:ID!):String!
    access(key:ID!, canLogin: Boolean!):String!
`;

export default { typeDef, query, mutation };
