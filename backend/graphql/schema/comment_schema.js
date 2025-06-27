const typeDef = `#graphql
type Commentaire{
    message: String! 
    date: Float!
    editer: User!
}
input CommentaireInput{
    message: String! 
    date: Float!
    editer:String!
}
`;
export default {typeDef};