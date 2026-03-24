const typeDef = `#graphql
  type paieCategorieGrille {
    _key: ID!
    libelle: String!
    classes: [Classe]      
  }
`;

const query = `#graphql
  categoriesPaieGrille(perPage: Int, skip: Int): [paieCategorieGrille]!
  paieCategorieGrille(key: ID!): paieCategorieGrille!
`;

const mutation = `#graphql
  createpaieCategorieGrille(libelle: String!, classes: [ClasseInput]! ): String!
  updatepaieCategorieGrille(key: ID!, libelle: String, classes: [ClasseInput]): String!
  deletepaieCategorieGrille(key: ID!): String!
`;

export default { typeDef, query, mutation };