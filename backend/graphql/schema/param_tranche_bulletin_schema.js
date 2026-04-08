const typeDef = `#graphql
# Le type de la valeur de la tranche
enum TrancheValueType {
  taux
  valeur
}

enum RubriqueRole {
  rubrique
  variable
}
# Le type valeur pour un pourcentage (avec base et taux)
type Taux {
  base: RubriqueBulletin!     # par ex. 100000
  taux: Float!     # par ex. 5 pour 5%
}

input TauxInput {
  base: String!
  taux: Float!
}

# Une valeur de type "taux" ou "valeur"
type TrancheValue {
  type: TrancheValueType!
  taux: Taux        # si type == pourcentage
  valeur: Float     # si type == valeur
}

input TrancheValueInput {
  type: TrancheValueType!
  taux: TauxInput
  valeur: Float
}

# Une tranche avec min, max, et sa valeur
type Tranche {
  min: Int!
  max: Int
  value: TrancheValue!
}

input TrancheInput {
  min: Int!
  max: Int
  value: TrancheValueInput!
}

# Un barème avec une base et une liste de tranches
type Bareme {
  reference: RubriqueBulletin!
  tranches: [Tranche!]!
}

input BaremeInput {
  reference: String!
  tranches: [TrancheInput!]!
}


enum BaseType {
  valeur    # une simple valeur numérique
  rubrique  # une autre rubrique
}

enum Opera {
  multiplication
  addition
  soustraction
  division
}

input ElementCalculInput {
  type: BaseType!
  valeur: Float
  calculRubriqueKey: String
}

input CalculInput {
  operateur: Opera!
  elements: [ElementCalculInput!]!
}
type ElementCalcul {
  type: BaseType!
  valeur: Float
  calculRubrique: RubriqueBulletin
}
type Calcul {
  operateur: Opera!
  elements: [ElementCalcul!]!
}

# Pour les entrées des données de calcul dans la base de donnée
input ElementCalculInputForRubriqueCategorieConfig {
  type: BaseType!
  valeur: Float
  calculRubrique: RubriqueBulletinInput
}
input CalculInputForRubriqueCategorieConfig{
  operateur: Opera!
  elements: [ElementCalculInput!]!
}


input TauxInputForRubriqueCategorieConfig {
  base: RubriqueBulletinInput!
  taux: Float!
}

input BaremeInputForRubriqueCategorieConfig {
  reference: RubriqueBulletinInput!
  tranches: [TrancheInput!]!
}
`;


export default { typeDef };
