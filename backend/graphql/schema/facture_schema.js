const typeDef = `#graphql

enum TypeFacture {
    recurrent
    punctual
}

enum StatusFacture {
    paid
    blocked
    tobepaid
    unpaid
    partialpaid
}

type Penalty {
    montant: Float!
    isPaid:Boolean!
    nombreRetard:Int! 
}
type OldPenalty {
    libelle: String! 
    montant: Float!
    nbreRetard:Int! 
}
# input PenaltyInput{
#     montant: Float! 
# }
type Facture {
    _id: ID!
    reference: String! 
    reduction: Reduction!
    tva: Boolean!
    tauxTVA: Float
    client: Client!
    blocked: Boolean
    dateEnregistrement:Float!
    ligneFactures: [LigneFacture]!
    status: StatusFacture!
    montant: Float!
    commentaires: [Commentaire]
    facturesAcompte: [FactureAcompte]
    type: TypeFacture!
    dateEtablissementFacture: Float!
    isConvertFromProforma: Boolean
    banques: [Banque!]!
    datePayementEcheante: Float
    payements: [FluxFinancier]

    #recurrente
    isDeletable: Boolean
    delaisPayment: Float
    dateDebutFacturation: Float
    generatePeriod: Float
    regenerate: Boolean
    secreteKey: String
}
`;
const query = `#graphql
    paidFactures(skip: Int, perPage: Int): [Facture]!
    facture(key: String!): Facture!
    factureByClient(clientId: String!): [Facture]!
    unpaidFacture(skip: Int, perPage: Int): [Facture]!
    blockedInvoice(skip: Int, perPage: Int): [Facture]!
    payementFacture(skip: Int, perPage: Int): [Facture]!
    recurrentFactureByClient(clientId: String!):[Facture]!
    newRecurrentFacture(skip: Int, perPage: Int):[Facture]!
`;

const mutation = `#graphql
    createFacture(
        dateEtablissementFacture: Float
        datePayementEcheante: Float
        dateDebutFacturation:Float
        type:TypeFacture
        tva: Boolean
        facturesAcompte: [FactureAcompteInput]
        clientId: String!
        generatePeriod: Float
        ligneFactures: [LigneFactureInput!]
        delaisPayment: Float
        banquesIds: [String!]!
    ): String!

    updateFacture(
        key: ID!
        dateEtablissementFacture: Float
        datePayementEcheante: Float
        dateDebutFacturation:Float
        reduction: ReductionInput
        tva: Boolean
        clientId: String
        generatePeriod: Float
        delaisPayment: Float
        banquesIds: [String]
        facturesAcompte: [FactureAcompteInput]
        commentaire: CommentaireInput
    ): String!

    updateFactureAccompte(
        key: ID!
        datePayementEcheante: Float
        dateEnvoieFacture: Float
        commentaire: CommentaireInput
        isSent:Boolean
        canPenalty: Boolean
        rang: Int!
    ): String!
    
    deleteFacture(key: ID!): String!
    
    stopperService(secretekey: String!): String!
    restartService(factureId: String!, secretekey: String!): String!

    ajouterPayement(
        key: ID!,
        montant: Float!,
        moyenPayement: MoyenPaiementInput!,
        pieceJustificative: Upload,
        referenceTransaction: String!
        userId: String,
        clientId: String!,
        bankId: String!
        dateOperation: Float
    ): String!

    ajouterLigneFacture(
        factureId: String!,
        serviceId: String!,
        designation: String!,
        unit: String!
        quantite: Int,
        prixSupplementaire: Float,
        dureeLivraison: Float, 
        remise: Float,
        fraisDivers: [FraisDiversInput]
    ): String!

    
`;
export default { typeDef, mutation, query };
