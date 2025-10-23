const typeDef = `#graphql
    enum RubriqueBulletinNature {
        constant
        taux
        calcul
        sommeRubrique
        bareme
    }

    enum RubriqueIdentity {
        anciennete
        nombrePersonneCharge
        netPayer
        avanceSurSalaire
    }

    enum RubriqueBulletinType {
        retenue
        gain
    }
    enum PorteeRubrique {
        individuel
        commun
    }
    
    type RubriqueBulletin {
        _id: ID!
        rubrique: String!
        code: String!
        type: RubriqueBulletinType
        nature: RubriqueBulletinNature!
        bareme: Bareme
        rubriqueRole: RubriqueRole
        portee: PorteeRubrique
        section: SectionBulletin
        taux: Taux
        rubriqueIdentity: RubriqueIdentity
        sommeRubrique: Calcul
        calcul: Calcul
    }
    input RubriqueBulletinInput {
        rubriqueId: ID!
        value: Float
    }
`;

const query = `#graphql
    rubriquesBulletin(perPage: Int, skip: Int): [RubriqueBulletin]!
    rubriqueBulletin(key: ID!): RubriqueBulletin
    primesExceptionnelles : [RubriqueBulletin]!
    # rubriqueBulletinBySection(sectionId: Int): RubriqueBulletin
`;

const mutation = `#graphql
    createRubriqueBulletin(
        rubrique: String!
        code: String!
        type: RubriqueBulletinType
        nature: RubriqueBulletinNature!
        bareme: BaremeInput
        sectionId: String
        portee: PorteeRubrique
        rubriqueRole: RubriqueRole
        taux: TauxInput
        rubriqueIdentity: RubriqueIdentity
        sommeRubrique: CalculInput
        calcul: CalculInput
    ): String!

    updateRubriqueBulletin(
        key: ID!,
        rubrique: String
        # code: String
        type: RubriqueBulletinType
        nature: RubriqueBulletinNature
        bareme: BaremeInput
        sectionId: String
        rubriqueRole: RubriqueRole
        portee: PorteeRubrique
        rubriqueIdentity: RubriqueIdentity
        taux: TauxInput
        sommeRubrique: CalculInput
        calcul: CalculInput
    ): String!

    # deleteBulletinRubrique(key: ID!): String!
`;

export default {
  typeDef,
  query,
  mutation,
};
