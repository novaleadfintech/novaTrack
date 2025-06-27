const typeDef = `#graphql
    enum EtatService{
        archived
        unarchived
    }
    enum NatureService{
        unique
        multiple
    }
    enum ServiceType{
        produit
        recurrent
        punctual
    }
    type ServiceTarif{
        minQuantity: Int!
        maxQuantity: Int
        prix: Float!
    }
    input ServiceTarifInput {
        minQuantity: Int!
        maxQuantity: Int
        prix: Float!
    }
    
    type Service {
        _id: ID!
        libelle: String!
        tarif: [ServiceTarif]
        type: ServiceType!
        etat: EtatService!
        nature: NatureService!
        prix: Float
        description: String
        country: Country!
        fullCount:Int
    }
`;

const query = `#graphql
    services(perPage: Int, skip: Int, etat: EtatService): [Service]!
    service(key: ID!): Service!
`;

const mutation = `#graphql
    createService(libelle: String!, tarif: [ServiceTarifInput], type: ServiceType!, etat: EtatService,nature : NatureService!, description: String, prix: Float, country:CountryInput!,): String!
    updateService(key: ID!, libelle: String, tarif:[ServiceTarifInput] , type: ServiceType, nature : NatureService, description: String, country:CountryInput, prix: Float): String!
    #deleteService(key: ID!): String!
    archivedService(key: ID!): String!
    unarchivedService(key: ID!): String!
`;

export default { typeDef, query, mutation };
