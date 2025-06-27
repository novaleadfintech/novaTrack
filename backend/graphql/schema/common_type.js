const typeDef = `#graphql
    scalar Upload

    enum Sexe{
        F
        M
    }

    enum Civilite{
        miss
        madam
        sir
    }

    enum SituationMatrimoniale{
        single, married, divorced, widowed
    }

    type File {
      filename: String!
      mimetype: String!
      url: String!
      content: String!
    },
`;

export default {typeDef};