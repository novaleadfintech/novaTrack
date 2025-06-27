const typeDef = `#graphql 

type FactureAcompte {
    rang: Int!
    pourcentage: Int!
    datePayementEcheante: Float
    dateEnvoieFacture: Float
    isPaid: Boolean!
    canPenalty: Boolean
    isSent: Boolean 
    penalty: Penalty
    oldPenalties: [OldPenalty] 
}

input FactureAcompteInput {
    rang: Int!
    pourcentage: Int!
    canPenalty: Boolean
    dateEnvoieFacture: Float
    datePayementEcheante: Float
    isPaid: Boolean!
}
`;

export default { typeDef, };
