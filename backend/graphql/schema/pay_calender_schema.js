const typeDef = `#graphql
type PayCalendar{
    _id:ID!
    libelle:String!
    dateDebut: Float!
    dateFin: Float!
}
input PayCalendarInput{
    _id:ID!
    libelle:String!
    dateDebut: Float!
    dateFin: Float!
}
`;

const query = `#graphql
    payCalendars(perPage:Int, skip:Int):[PayCalendar]!
    payCalendar(key:ID!):PayCalendar!   
`;

const mutation = `#graphql
    createPayCalendar(libelle:String!, dateDebut: Float!, dateFin: Float!):String!
    updatePayCalendar(key:ID!, libelle:String, dateDebut: Float, dateFin: Float):String!
    deletePayCalendar(key:ID!):String!
`;

export default { typeDef, query, mutation };
