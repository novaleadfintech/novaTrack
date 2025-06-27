const typeDef = `#graphql

    enum EtatClient{
        archived
        unarchived
    }

    enum NatureClient {
        prospect
        client
        fournisseur
    }

    type Responsable {
        prenom: String!
        nom: String!
        email: String!
        telephone: Float!
        civilite: Civilite!
        sexe: Sexe!
        poste: String!
    }
    input ResponsableInput {
        prenom: String!
        nom: String!
        email: String!
        telephone: Float!
        civilite: Civilite!
        sexe: Sexe!
        poste: String!
    }

    #Definition du type client
    interface Client{
        _id:ID!
        email:String!
        telephone:Float!
        adresse:String! 
        pays:Country!
        nature: NatureClient!      
        etat:EtatClient!            
        dateEnregistrement:Float!
        fullCount:Int
    }

    type ClientMoral implements Client{
        _id:ID!
        raisonSociale:String!
        logo:String
        email:String!
        nature: NatureClient!      
        telephone:Float!
        pays:Country!
        adresse:String!
        categorie:Categorie!
        etat:EtatClient!
        responsable:Responsable!
        dateEnregistrement:Float!
        fullCount:Int
    }

    type ClientPhysique implements Client {
        _id: ID!
        nom: String!
        prenom: String
        sexe: Sexe!
        pays:Country!        
        nature: NatureClient!      
        email: String!
        telephone: Float!
        adresse: String!        
        etat: EtatClient!            
        dateEnregistrement: Float!
        fullCount: Int
    }
`;

const query = `#graphql

    clients(skip:Int, perPage:Int, etat: EtatClient, nature: NatureClient): [Client]!
    client(key:ID!): Client!
    unarchivedClientsAndProspects(skip:Int, perPage:Int,):[Client]!
    #clientMoralsByCategorie(skip:Int, perPage:Int, categorieId:String!): [ClientMoral]!
`;

const mutation = `#graphql
    createClientPhysique(
        nom:String!
        prenom:String!
        sexe:Sexe!
        email:String!
        nature: NatureClient!      
        telephone:Float!
        pays:CountryInput!
        adresse:String!
        etat:EtatClient
    ):String!

    createClientMoral(
        raisonSociale:String!
        logo:Upload
        email:String!
        telephone:Float!
        adresse:String!
        nature: NatureClient!      
        pays:CountryInput!
        categorieId: String!
        etat: EtatClient
        responsable: ResponsableInput!
    ):String!

    updateClientPhysique(
        key: ID!
        nom: String
        prenom: String
        sexe: Sexe
        nature: NatureClient     
        email: String
        pays: CountryInput
        telephone: Int
        adresse: String
    ):String!

    updateClientMoral(
        key:ID!
        raisonSociale:String
        logo: Upload
        email: String
        telephone: Float
        adresse: String
        nature: NatureClient    
        pays: CountryInput
        categorieId: String
        responsable: ResponsableInput
    ):String!

    #deleteClient(key:String!): String!

    unarchivedClient(key:String!): String!

    archivedClient(key:String!): String!
`;

export default { typeDef, query, mutation };
