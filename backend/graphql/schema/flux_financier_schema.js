const typeDef = `#graphql
    enum FluxFinancierType{
       input
       output 
    }
    enum FluxFinancierStatus{
       wait
       reject
       valid
       returne
    }

    enum BuyingManner{
        total
        partial
        credit
    }

    type Bilan{
        fluxFinanciers:[FluxFinancier]!
        total:Float!
        input:Float!
        output:Float!
    }
    type ValidateFlux{
        validateStatus:FluxFinancierStatus!
        validater:User!
        date:Float!
        commentaire: String!

    }
    input ValidateFluxInput{
        validateStatus:FluxFinancierStatus!
        validater:String!
        date:Float!
        commentaire: String!
    }

    type MonthBilan{
        mois:Int!
        input:Float!
        output:Float!
    }

    type TranchePayement{
        datePayement: Float!
        montantPaye: Float!
    }

    input TranchePayementInput{
        datePayement: Float!
        montantPaye: Float!
    }
    
    type FluxFinancier{
        _id:ID!
        libelle:String!
        reference:String
        type:FluxFinancierType!
        montant:Float!
        moyenPayement: MoyenPaiement!
        validate: [ValidateFlux]
        referenceTransaction: String
        status: FluxFinancierStatus
        dateOperation:Float!
        isFromSystem: Boolean,
        dateEnregistrement:Float!
        pieceJustificative: String
        user: User #userId
        client: Client
        bank:Banque! 
        factureId: String #factureId
    }
`;

const query = `#graphql
    fluxFinanciers(perPage:Int, skip:Int, type: FluxFinancierType,): [FluxFinancier]!
    debtFluxFinanciers(perPage:Int, skip:Int,): [FluxFinancier]!
    unValidatedFluxFinanciers(perPage:Int, skip:Int, type: FluxFinancierType,): [FluxFinancier]!
    archiveFluxFinanciers(perPage:Int, skip:Int,): [FluxFinancier]!
    fluxFinancier(key:ID!): FluxFinancier!
    fluxFiancierbyFacture(factureId:String!): [FluxFinancier]!
    fluxFinanciersByBank(banque:String!, debut: Float!, fin:Float!, status: FluxFinancierStatus): [FluxFinancier]!
    bilan(begin:Float, end:Float, type: FluxFinancierType,): Bilan!
    yearBilan(year:Int):[MonthBilan]!
`;

const mutation = `#graphql
    createFluxFinancier(
        libelle:String!,
        reference:String,
        type:FluxFinancierType!,
        montant:Float!,
        moyenPayement: MoyenPaiementInput!,
        pieceJustificative:Upload,
        userId: String!,
        referenceTransaction: String!
        dateOperation:Float
        factureId:String,
        bankId: String!
        clientId: String!
    ):String!

    updateFluxFinancier(
        key:ID!,
        libelle:String,
        type:FluxFinancierType,
        montant:Float,
        dateOperation:Float,
        referenceTransaction: String
        commentaire: CommentaireInput,
        moyenPayement: MoyenPaiementInput,
        pieceJustificative:Upload,
        bankId: String,
        clientId: String,
    ):String!

    validateFluxFinancier(
        key:ID!,
        validate: ValidateFluxInput!
    ):String!

    deleteFluxFinancier(key:ID!):String!
`;

export default { typeDef, query, mutation };