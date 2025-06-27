const typeDef = `#graphql
type LibelleFlux{
    _id:ID!
     libelle:String!
    type: FluxFinancierType!
}
`;

const query = `#graphql
    libelleFlux(perPage:Int, skip:Int, type: FluxFinancierType):[LibelleFlux]!
    #libelleFlux(key:ID!):LibelleFlux!
`;

const mutation = `#graphql
    createLibelleFlux(libelle:String!, type: FluxFinancierType!,  ):String!
    updateLibelleFlux(key:ID!, libelle:String, ):String!
    deleteLibelleFlux(key:ID!):String!
`;

export default { typeDef, query, mutation };
