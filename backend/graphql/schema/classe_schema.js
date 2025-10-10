const typeDef = `#graphql
  type EchelonIndice {
    echelon: Echelon!    
    indice: Int   
  }
  input EchelonIndiceInput {
    echelon: EchelonInput!    
    indice: Int   
  }
  type Classe{
    _id:ID!
    libelle:String!
    echelonIndiciciaires:[EchelonIndice]!
  }
  input ClasseInput{
    _id:ID!
    libelle:String!
    classes:[EchelonIndiceInput]!
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
createClasse(libelle: String!, echelonIndiciciaires:[EchelonIndiceInput]!): String!
updateClasse(key: ID!, libelle: String, echelonIndiciciaires:[EchelonIndiceInput]): String!
deleteClasse(key: ID!): String!
`;

export default { typeDef, query, mutation };
