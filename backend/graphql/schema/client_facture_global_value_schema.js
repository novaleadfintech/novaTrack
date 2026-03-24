const typeDef = `#graphql
    type ClientFactureGlobaLValue {
        client: Client!
        nbreJrMaxPenalty: Int
    }
`;

const query = `#graphql
    clientFactureGlobalValues: [ClientFactureGlobaLValue]
    # rubriqueBulletinBypaieCategorieForConfiguration(paieCategorieKey: String): [BulletinCategorieRubrique]!
`;

const mutation = `#graphql
    configClientFactureGlobaLValue(clientKey:String!, nbreJrMaxPenalty: Float): String!
    # deleteBulletinCategorieRubrique(partnerCategorieKey:String,rubriqueKey: KEY!): String!
`;

export default {
  typeDef,
  query,
  mutation,
};
