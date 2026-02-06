const typeDef = `#graphql
   
    enum DebtStatus{
        paid
        unpaid
      }

    type Debt{
        _id:ID!
        libelle:String!
        montant:Float!
        referenceFacture: String
        status: DebtStatus
        datePayementUlterieur:Float
        dateOperation:Float!
        partiePrenante: String
        dateEnregistrement:Float!
        pieceJustificative: String
        user: User #userId
        client: Client
     }
`;

const query = `#graphql
    debts(perPage:Int, skip:Int): [Debt]!
     debt(key:ID!): Debt!
 `;

const mutation = `#graphql
    createDebt(
        libelle:String!,
         montant:Float!,
         pieceJustificative:Upload,
        userId: String!,
        datePayementUlterieur:Float,
        partiePrenante: String,
        referenceFacture: String!
        dateOperation:Float
          clientId: String
    ):String!

    updateDebt(
        key:ID!,
        libelle:String,
         montant:Float,
        dateOperation:Float,
        referenceFacture: String
        status: DebtStatus,
         pieceJustificative:Upload,
         partiePrenante: String,
        datePayementUlterieur:Float,
         clientId: String,
    ):String!

      deleteDebt(key:ID!):String!
`;

export default { typeDef, query, mutation };