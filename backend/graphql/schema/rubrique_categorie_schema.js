const typeDef = `#graphql
       type RubriqueOnBulletin {
        rubrique: RubriqueBulletin!
        value: Float
    }

    type CategorieRubrique {
        rubriqueCategorie: RubriqueOnBulletin!
        isChecked: Boolean!
    }
`;

const query = `#graphql
    rubriqueBulletinByCategoriePaie(categoriePaieId: String): [RubriqueOnBulletin]!
    rubriqueBulletinByCategoriePaieForConfiguration(categoriePaieId: String): [CategorieRubrique]!
`;

const mutation = `#graphql
    
    createRubriqueCategorie(categorieId:String!, rubriqueId: ID!, value: Float): String!
    updateRubriqueCategorie(categorieId:String,rubriqueId: ID!, value: Float): String!
    deleteRubriqueCategorie(categorieId:String,rubriqueId: ID!): String!

  
`;

export default {
  typeDef,
  query,
  mutation,
};
