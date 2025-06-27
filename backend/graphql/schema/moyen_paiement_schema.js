const typeDef = `#graphql
type MoyenPaiement{
    _id:ID!
    type: CanalType
    libelle:String!
}

input MoyenPaiementInput{
    _id:ID!
    type: CanalType
    libelle:String!
}
`;

const query = `#graphql
    moyensPaiement(perPage:Int, skip:Int):[MoyenPaiement]!
    moyenPaiement(key:ID!):MoyenPaiement!
`;

const mutation = `#graphql
    createMoyenPaiement(libelle:String!, type: CanalType
!    ):String!
    updateMoyenPaiement(key:ID!, libelle:String,        type: CanalType
    ):String!
    deleteMoyenPaiement(key:ID!):String!
`;

export default { typeDef, query, mutation };
