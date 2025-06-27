const typeDef = `#graphql
    type Country {
      _id: ID
      name: String!
      code: Int!
      tauxTVA: Float
      phoneNumber: Int
      initiauxPays: [Int]
    }

    input CountryInput {
      _id: ID
      name: String!
      code: Int!
      tauxTVA: Float
      phoneNumber: Int
    initiauxPays: [Int]

    }
`;

const query = `#graphql
    allCountries(perPage: Int, skip: Int): [Country]!
    country(id: ID!): Country!
`;

const mutation = `#graphql
    createCountry(name: String!, code:Int!, phoneNumber:Int!, tauxTVA: Float!,       initiauxPays: [Int]!,
): String!
    updateCountry(key: ID!, name: String, code:Int, phoneNumber:Int tauxTVA: Float,      initiauxPays: [Int],
): String!
`;

export default { typeDef, query, mutation };
