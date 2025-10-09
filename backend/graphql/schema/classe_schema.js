const typeDef = `#graphql
  type EchelonIndice {
    _id: ID!
    echelon: Echelon!    
    indice: Int   
  }
  input EchelonIndiceInput {
    _id: ID!
    echelon: EchelonInput!    
    indice: Int   
  }
  type Classe{
    _id:ID!
    libelle:String!
    echelonIndices:[EchelonIndice]!
  }
`;

const query = `#graphql
#   echelonIndices(perPage: Int, skip: Int): [EchelonIndice]!
#   echelonIndice(key: ID!): EchelonIndice!
classes(perPage: Int, skip: Int): [Classe]!
classe(key: ID!): Classe!
`;

const mutation = `#graphql
#   createEchelonIndice(echelonId: ID!, indice: Int!): String!
#   updateEchelonIndice(key: ID!, echelonId: ID, indice: Int): String!
#   deleteEchelonIndice(key: ID!): String!
createClasse(libelle: String!, echelonIndiciciare:EchelonIndiceInput!): String!
updateClasse(key: ID!, libelle: String, echelonIndiciciares:[EchelonIndiceInput]): String!
deleteClasse(key: ID!): String!
`;

export default { typeDef, query, mutation };
