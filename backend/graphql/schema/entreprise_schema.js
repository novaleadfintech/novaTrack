
const typeDef = `#graphql
    type Entreprise{
        _id:ID!
        logo:String
        adresse:String
        ville:String
        email:String
        valeurIndiciaire:Int
        raisonSociale: String
        pays: Country
        telephone:Int
        tamponSignature:String
        nomDG:String
    }
`;
const query = `#graphql
    entreprise: Entreprise
    getValeurIndiciaire: Int
`;

const mutation = `#graphql
    createEntreprise(
        logo:Upload,
        adresse:String,
        raisonSociale: String,
        pays: String,
        email:String,
        valeurIndiciaire:Int
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
        valeurIndiciaire:Int
        raisonSociale: String,
        telephone:Int,
        tamponSignature:Upload,
        nomDG:String,
    ):String!
`;

export default { typeDef, query, mutation };
