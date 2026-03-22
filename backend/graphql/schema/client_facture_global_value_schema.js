const typeDef = `#graphql
    type ClientFactureGlobaLValue {
        client: Client!
        nbreJrMaxPenalty: Int
    }
`;

const query = `#graphql
    clientFactureGlobalValues: [ClientFactureGlobaLValue]
    # rubriqueBulletinByCategoriePaieForConfiguration(categoriePaieId: String): [CategorieBulletinRubrique]!
`;

const mutation = `#graphql
    configClientFactureGlobaLValue(clientId:String!, nbreJrMaxPenalty: Float): String!
    # deleteCategorieBulletinRubrique(categorieId:String,rubriqueId: ID!): String!
`;

export default {
  typeDef,
  query,
  mutation,
};
