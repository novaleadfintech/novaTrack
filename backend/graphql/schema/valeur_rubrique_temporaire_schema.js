const typeDef = `#graphql
 
type ValeurRubriqueTemporaire {
  _id: ID
   salarieId: ID!
  rubriques: [RubriqueOnBulletin!]!
  primesExceptionnelles: [RubriqueOnBulletin]
}

input ValeurRubriqueTemporaireInput {
  id: Int
  salarieId: ID!
  rubriques: [RubriqueBulletinInput!]!
  primesExceptionnelles: [RubriqueBulletinInput!]!
}

`;
const query = `#graphql
   getValeurRubriqueTemporaireBySalarie(salarieId: ID!): ValeurRubriqueTemporaire
`;

const mutation = `#graphql
    createValeurRubriqueTemporaire(salarieId: ID!, rubriques: [RubriqueBulletinInput!]!, primesExceptionnelles: [RubriqueBulletinInput!]!): String!
    updateValeurRubriqueTemporaire(id: ID!, input: ValeurRubriqueTemporaireInput!): String!
    deleteValeurRubriqueTemporaire(id: ID!): Boolean!
`;

export default { typeDef, query, mutation };
