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
  rubriques: [RubriqueBulletinInput!]!
  primesExceptionnelles: [RubriqueBulletinInput!]!
}

`;
const query = `#graphql
   getValeurRubriqueTemporaireBySalarie(salarieKey: ID!): ValeurRubriqueTemporaire
`;

const mutation = `#graphql
    createValeurRubriqueTemporaire(salarieKey: ID!, rubriques: [RubriqueBulletinInput!]!, primesExceptionnelles: [RubriqueBulletinInput!]!): String!
    updateValeurRubriqueTemporaire(id: ID!, input: ValeurRubriqueTemporaireInput!): String!
    deleteValeurRubriqueTemporaire(key: ID!): Boolean!
`;

export default { typeDef, query, mutation };