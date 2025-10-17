const typeDef = `#graphql
type PayCalendar{
    _id:ID!
    libelle:String!
    dateDebut: Int!
    dateFin: Int!
}
input PayCalendarInput{
    _id:ID!
    libelle:String!
    dateDebut: Int!
    dateFin: Int!
}
`;

const query = `#graphql
    payCalendars(perPage:Int, skip:Int):[PayCalendar]!
    payCalendars(key:ID!):PayCalendar!   
`;

const mutation = `#graphql
    createPayCalendar(libelle:String!, dateDebut: Int!, dateFin: Int!):String!
    updatePayCalendar(key:ID!, libelle:String, dateDebut: Int, dateFin: Int):String!
    deletePayCalendar(key:ID!):String!
`;

export default { typeDef, query, mutation };
