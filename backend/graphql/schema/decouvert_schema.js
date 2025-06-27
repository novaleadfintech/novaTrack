const typeDef = `#graphql 
type Decouverte {
    _id: ID!
    justification: String!
    montant: Float!
    dateEnregistrement: String!
    montantRestant: Float!
    dureeReversement: Int!
    referenceTransaction: String!
    status: DecouverteStatus!
    moyenPayement: MoyenPaiement!
    banque: Banque!
    salarie: Salarie!
    #user: User!
}

enum DecouverteStatus {
    paid
    partialpaid
    unpaid
}

input DecouverteInput {
    justification: String!
    montant: Float!
    dureeReversement: Int!
    moyenPayement: MoyenPaiementInput!
    referenceTransaction: String!
    status: DecouverteStatus!
    banqueId: String!
    salarieId: String!
    userId: String!
}`;
const query = `#graphql 
    decouvertes(perPage: Int, skip: Int): [Decouverte]!
    decouverte(key: ID!): Decouverte!
`;

const mutation = `#graphql
    createDecouverte(
        justification: String!
        montant: Float!
        dureeReversement: Int!
        referenceTransaction: String!
        moyenPayement: MoyenPaiementInput!
        banqueId: String!
        salarieId: ID!
        userId: ID!
    ): String!
    updateDecouverte(
        key: ID!,
        justification: String
        montant: Float
        dureeReversement: Int
        referenceTransaction: String
        moyenPayement: MoyenPaiementInput
        banqueId:String
        salarieId: ID
        montantRestant: Float
    ): String!
    # deleteDecouverte(key: ID!): String!
`;

export default { typeDef, query, mutation };
