const typeDef = `#graphql

enum CanalType{
        banque
        operateurMobile
        caisse
    }

   type Banque {
        _id:ID!
        name:String!
        codeGuichet: String!
        codeBanque: String!
        cleRIB: String!
        codeBIC: String
        type: CanalType
        numCompte: String
        logo: String
        soldeReel: Float
        soldeTheorique: Float
        country:Country!
    }

    input BanqueInput {
        name:String!
        codeGuichet: String!
        codeBanque: String!
        codeBIC: String!
        type: CanalType
    numCompte: String!
        cleRIB: String!
        logo: Upload
        soldeReel: Float
        soldeTheorique: Float
        country: CountryInput!
    }`;

const query = `#graphql
    banques(perPage:Int, skip:Int,): [Banque]!
    banque(key:ID!): Banque!
`;

const mutation = `#graphql
    createBanque(
        name:String!
        codeGuichet: String!
        codeBanque: String!
        cleRIB: String!
        codeBIC: String
        type: CanalType!
        numCompte: String
        country: CountryInput!
        logo: Upload
        # soldeReel: Float
    ):String!

    updateBanque(
        key:ID!,
        name:String
        codeGuichet: String
        codeBIC: String
        type: CanalType
        numCompte: String
        codeBanque: String
        country: CountryInput
        cleRIB: String
        logo: Upload
    ):String!

    # resetBanqueAmount(
    #     key:ID!,
    #     soldeReel: Float!
    # ):String!

    deleteBanque(key:ID!):String!
`;

export default { typeDef, query, mutation };
