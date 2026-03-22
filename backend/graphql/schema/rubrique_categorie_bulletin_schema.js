const typeDef = `#graphql
       type RubriqueOnBulletin {
        rubrique: RubriqueBulletin!
        value: Float
    }

    type CategorieBulletinRubrique {
        rubriqueOnBulletin: RubriqueOnBulletin!
        isChecked: Boolean!
    }
`;

const query = `#graphql
    rubriqueBulletinByCategorieBulletin(categorieBulletinId: String): [RubriqueOnBulletin]!
    variablePaieAndPrimeExceptionnelles(categorieBulletinId: String!, salarieId: String!): ValeurRubriqueTemporaire
    rubriqueBulletinByCategorieBulletinForConfiguration(categorieBulletinId: String): [CategorieBulletinRubrique]!
`;

const mutation = `#graphql
    createCategorieBulletinRubrique(categorieBulletinId:String!, rubriqueId: ID!, value: Float): String!
    updateCategorieBulletinRubriqueBulletin(categorieBulletinId:String,rubriqueId: ID!, value: Float): String!
    deleteCategorieBulletinRubriqueBulletin(categorieBulletinId:String,rubriqueId: ID!): String!
`;

export default {
  typeDef,
  query,
  mutation,
};
