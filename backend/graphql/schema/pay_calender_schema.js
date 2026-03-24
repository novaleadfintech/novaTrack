const typeDef = `#graphql
type PayCalendar{
    _key:ID!
    libelle:String!
    dateDebut: Float!
    dateFin: Float!
    etat: EtatPayCalendar
}
input PayCalendarInput{
    _key:ID!
    libelle:String!
    dateDebut: Float!
    dateFin: Float!
    etat: EtatPayCalendar!
}

enum EtatPayCalendar{
    opened
    closed
    tobeOpen
}
`;

const query = `#graphql
    payCalendars(perPage:Int, skip:Int):[PayCalendar]!
    payCalendar(key:ID!):PayCalendar!   
`;

const mutation = `#graphql
    createPayCalendar(libelle:String!, dateDebut: Float!, dateFin: Float!):String!
    updatePayCalendar(key:ID!, libelle:String, dateDebut: Float, dateFin: Float):String!
    changeEtatPayPeriod(key:ID!, etat:EtatPayCalendar!):String!
    deletePayCalendar(key:ID!):String!
`;

export default { typeDef, query, mutation };
