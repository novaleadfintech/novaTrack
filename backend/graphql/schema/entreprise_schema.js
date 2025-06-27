
const typeDef = `#graphql
    type Entreprise{
        _id:ID!
        logo:String
        adresse:String
        ville:String
        email:String
        raisonSociale: String
        pays: Country
        telephone:Int
        tamponSignature:String
        nomDG:String
    }
`;
const query = `#graphql
    entreprise: Entreprise
`;

const mutation = `#graphql
    createEntreprise(
        logo:Upload,
        adresse:String,
        raisonSociale: String,
        pays: String,
        email:String,
        ville: String,
        telephone:Int,
        tamponSignature:Upload,
        nomDG:String,
    ):String!
    
    updateEntreprise(
        key:ID,
        logo:Upload,
        adresse:String,
        email:String,
        ville:String,
        pays: String,
        raisonSociale: String,
        telephone:Int,
        tamponSignature:Upload,
        nomDG:String,
    ):String!
`;

export default { typeDef, query, mutation };
