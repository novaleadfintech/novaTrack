const typeDef = `#graphql
 
type ValeurRubriqueTemporaire {
  _id: ID
   salarieId: ID!
  rubriques: [RubriqueOnBulletin!]!
}

input ValeurRubriqueTemporaireInput {
  id: Int
  salarieId: ID!
  rubriques: [RubriqueOnBulletinInput!]!
}

`;
const query = `#graphql
   getValeurRubriqueTemporaireBySalarie(salarieId: ID!): ValeurRubriqueTemporaire
`;

const mutation = `#graphql
    createValeurRubriqueTemporaire(input: ValeurRubriqueTemporaireInput!): ValeurRubriqueTemporaire!
    updateValeurRubriqueTemporaire(id: ID!, input: ValeurRubriqueTemporaireInput!): ValeurRubriqueTemporaire!
    deleteValeurRubriqueTemporaire(id: ID!): Boolean!
`;

export default { typeDef, query, mutation };
