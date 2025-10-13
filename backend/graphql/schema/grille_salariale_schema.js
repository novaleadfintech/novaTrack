const typeDef = `#graphql
  type CategoriePaieGrille {
    _id: ID!
    libelle: String!
    classes: [Classe]      
  }
`;

const query = `#graphql
  categoriesPaieGrille(perPage: Int, skip: Int): [CategoriePaieGrille]!
  categoriePaieGrille(key: ID!): CategoriePaieGrille!
`;

const mutation = `#graphql
  createCategoriePaieGrille(libelle: String!, classes: [ClasseInput]! ): String!
  updateCategoriePaieGrille(key: ID!, libelle: String, classes: [ClasseInput]): String!
  deleteCategoriePaieGrille(key: ID!): String!
`;

export default { typeDef, query, mutation };
