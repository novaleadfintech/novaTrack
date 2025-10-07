const typeDef = `#graphql
  type CategoriePaieGrille {
    _id: ID!
    libelle: String!
    classes: [Classe]     # Relation vers les classes de la catégorie
  }
`;

const query = `#graphql
  categoriesPaieGrille(perPage: Int, skip: Int): [CategoriePaieGrille]!
  categoriePaieGrille(key: ID!): CategoriePaieGrille!
`;

const mutation = `#graphql
  createCategoriePaieGrille(libelle: String!): String!
  updateCategoriePaieGrille(key: ID!, libelle: String): String!
  deleteCategoriePaieGrille(key: ID!): String!
`;

export default { typeDef, query, mutation };
