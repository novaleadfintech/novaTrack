const typeDef = `#graphql
enum EtatPersonnel{
        archived
        unarchived
    }
    enum TypePersonnel {
        stagiaire
        consultant
        employe
        interim
        freelance
    }
    enum TypeContrat{
        cdi
        cdd
        alternance
        apprentissage
        missionInterim
        conventionDeStage
        prestationDeService
        consultantFreelance
        contratFreelance
    }

type PersonnePrevenir{
    nom: String!
    lien: String!
    telephone1: Float!
    telephone2: Float
}
input PersonnePrevenirInput{
    nom: String!
    lien: String!
    telephone1: Float!
    telephone2: Float
}
 #definition du type personnel
       type Personnel{
        _id:ID!
        nom:String!
        prenom:String!
        email:String!
        pays:Country!
        telephone:Float!
        adresse:String
        sexe:Sexe!        
        poste:String!
        situationMatrimoniale:SituationMatrimoniale!
        commentaire:String
        etat:EtatPersonnel!
        dateEnregistrement:Float!
        dateNaissance: Float!
        dateDebut: Float!
        dateFin: Float
        nombreEnfant: Int!
        nombrePersonneCharge: Int!       
        dureeEssai:Float
        typePersonnel: TypePersonnel!
        typeContrat: TypeContrat
        personnePrevenir: PersonnePrevenir!
        fullCount:Int
    }

    # input PersonnelInput{
    #     nom:String!
    #     prenom:String!
    #     email:String!
    #     pays:CountryInput!
    #     telephone:Float!
    #     adresse:String
    #     sexe:Sexe!
    #     poste:String!
    #     situationMatrimoniale:SituationMatrimoniale!
    #     commentaire:String
    #     etat:EtatPersonnel!
    #     dateEnregistrement:Float!
    # }
`;

const query = `#graphql
        personnels(skip:Int, perPage:Int, etat: EtatPersonnel,):[Personnel]!
        personnel(key:ID!):Personnel!
    `;

const mutation = `#graphql
        createPersonnel(
            nom:String!,
            prenom:String!,
            email:String!,
            pays:String!
            telephone:Float!,
            sexe:Sexe!,
            poste:String!,
            situationMatrimoniale:SituationMatrimoniale!,
            etat:EtatPersonnel
            adresse:String,
            dateNaissance: Float!
            dateDebut: Float!
            dateFin: Float        
            dureeEssai:Float
            nombreEnfant: Int!
            nombrePersonneCharge: Int!
            typePersonnel: TypePersonnel!
            typeContrat: TypeContrat
            personnePrevenir: PersonnePrevenirInput!
            commentaire:String,
        ):String!,

        updatePersonnel(
            key:ID!, 
            nom:String,
            prenom:String,
            email:String,
            pays:String
            telephone:Float,
            sexe:Sexe,
            poste:String,
            situationMatrimoniale:SituationMatrimoniale,
            adresse:String,
            dureeEssai:Float
            commentaire:String,
            dateNaissance: Float
            dateDebut: Float
            dateFin: Float
            nombreEnfant: Int
            nombrePersonneCharge: Int
            typePersonnel: TypePersonnel
            typeContrat: TypeContrat
            personnePrevenir: PersonnePrevenirInput
        ):String!,

        #deletePersonnel(key:ID!):String!
        
        archivedPersonnel(key:ID!):String!

        unarchivedPersonnel(key:ID!):String!
    `;

export default { typeDef, query, mutation };
