const typeDef = `#graphql

enum StatusProforma {
    wait
    cancel
    validated
    archived,
}

type Proforma {
    _key: ID!
    reference: String! 
    reduction: Reduction!
    tva: Boolean!
    tauxTVA: Float
    client: Client!
    dateEnregistrement:Float!
    ligneProformas: [LigneProforma]!
    status: StatusProforma!
    montant: Float!
    dateEtablissementProforma: Float
    garantyTime: Float
    dateEnvoie: Float
}
`;
const query = `#graphql
   proformas(skip: Int, perPage: Int,): [Proforma]!
   archivedProformas: [Proforma]!
   Proforma(key: String!): Proforma!
   proformaByClient(clientKey: String!): [Proforma]!
`;

const mutation = `#graphql
    createProforma(
        dateEtablissementProforma: Float
        garantyTime: Float
        dateEnvoie: Float
        tva: Boolean
        clientKey: String!
        ligneProformas: [LigneProformaInput!]
    ): String!

    updateProforma(
        key: ID!
        dateEtablissementProforma: Float
        garantyTime: Float
        dateEnvoie: Float
        reduction: ReductionInput
        tva: Boolean
        clientKey: String
        status: StatusProforma
    ): String!
    
    deleteProforma(key: ID!): String!
    
    validerProforma(key: ID!, dateEtablissementFacture: Float, facturesAcompte: [FactureAcompteInput!]!, banquesKeys: [String!]!,): String!

    annulerValidationProforma(key: ID!): String!

    annulerProformaProformat(key: ID!): String!

    ajouterLigneProforma(
        proformaKey: String!,
        serviceKey: String!,
        designation: String!,
        unit: String!
        prixSupplementaire: Float,
        quantite: Int,
        dureeLivraison: Float, 
        remise: Float,
        fraisDivers: [FraisDiversInput]
    ): String! 
`;
export default { typeDef, mutation, query };