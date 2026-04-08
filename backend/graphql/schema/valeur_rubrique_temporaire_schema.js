const typeDef = `#graphql
 
type ValeurRubriqueTemporaire {
  _key: ID
   salarieKey: ID!
  rubriques: [RubriqueOnBulletin!]!
  primesExceptionnelles: [RubriqueOnBulletin]
}

input ValeurRubriqueTemporaireInput {
  key: Int
  salarieKey: ID!
  rubriques: [RubriqueOnBulletinInput!]!
  primesExceptionnelles: [RubriqueOnBulletinInput!]!
}

`;
const query = `#graphql
   getValeurRubriqueTemporaireBySalarie(salarieKey: ID!): ValeurRubriqueTemporaire
`;

const mutation = `#graphql
    createValeurRubriqueTemporaire(salarieKey: ID!, rubriques: [RubriqueOnBulletinInput!]!, primesExceptionnelles: [RubriqueOnBulletinInput!]!): String!
    updateValeurRubriqueTemporaire(id: ID!, input: ValeurRubriqueTemporaireInput!): String!
    deleteValeurRubriqueTemporaire(key: ID!): Boolean!
`;

export default { typeDef, query, mutation };