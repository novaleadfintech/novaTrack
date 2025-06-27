const typeDef = `#graphql
type Creance{
    client: Client!
    factures: [Facture]!
    montantRestant: Float!
}`;

const query = `#graphql
    creancesTobePay(begin:Float, end:Float): [Creance]!
    unpaidCreances(begin:Float, end:Float): [Creance]!
    getDailyClaim:[Creance]!
`;
export default { typeDef, query };
