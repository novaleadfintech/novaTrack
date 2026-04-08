const typeDef = `#graphql
    type RubriqueOnBulletin {
        rubrique: RubriqueBulletin!
        value: Float
    }

    type BulletinCategorieRubrique {
        rubriqueOnBulletin: RubriqueOnBulletin!
        isChecked: Boolean!
    }

    type RubriqueCategorieConfig {
        _key: ID
        bulletinCategorieKey: String!
        rubriquesOnBulletin: [RubriqueOnBulletin]!
    }

    input RubriqueOnBulletinInput {
        bulletinRubrique: RubriqueBulletinInput!
        value: Float
    }
`;

const query = `#graphql
    rubriqueBulletinByBulletinCategorie(bulletinCategorieKey: String): [RubriqueOnBulletin]!
    variablePaieAndPrimeExceptionnelles(bulletinCategorieKey: String!, salarieKey: String!): ValeurRubriqueTemporaire
    rubriqueBulletinByBulletinCategorieForConfiguration(bulletinCategorieKey: String): [BulletinCategorieRubrique]!
    # getRubriqueCategorieConfig(bulletinCategorieKey: String!): RubriqueCategorieConfig
`;

const mutation = `#graphql
    # createBulletinCategorieRubrique(bulletinCategorieKey:String!, rubriqueKey: ID!, value: Float): String!
    # updateBulletinCategorieRubriqueBulletin(bulletinCategorieKey:String,rubriqueKey: ID!, value: Float): String!
    # deleteBulletinCategorieRubriqueBulletin(bulletinCategorieKey:String,rubriqueKey: ID!): String!
    saveRubriqueCategorieConfig(bulletinCategorieKey: String!, rubriquesConfiged: [RubriqueOnBulletinInput]!): String!
`;

export default {
  typeDef,
  query,
  mutation,
};