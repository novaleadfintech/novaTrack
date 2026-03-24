const typeDef = `#graphql
       type RubriqueOnBulletin {
        rubrique: RubriqueBulletin!
        value: Float
    }

    type BulletinCategorieRubrique {
        rubriqueOnBulletin: RubriqueOnBulletin!
        isChecked: Boolean!
    }
`;

const query = `#graphql
    rubriqueBulletinByBulletinCategorie(bulletinCategorieKey: String): [RubriqueOnBulletin]!
    variablePaieAndPrimeExceptionnelles(bulletinCategorieKey: String!, salarieKey: String!): ValeurRubriqueTemporaire
    rubriqueBulletinByBulletinCategorieForConfiguration(bulletinCategorieKey: String): [BulletinCategorieRubrique]!
`;

const mutation = `#graphql
    createBulletinCategorieRubrique(bulletinCategorieKey:String!, rubriqueKey: ID!, value: Float): String!
    updateBulletinCategorieRubriqueBulletin(bulletinCategorieKeyy:String,rubriqueKey: ID!, value: Float): String!
    deleteBulletinCategorieRubriqueBulletin(bulletinCategorieKeyy:String,rubriqueKey: ID!): String!
`;

export default {
  typeDef,
  query,
  mutation,
};