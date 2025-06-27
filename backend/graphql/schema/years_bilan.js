const typeDef = `#graphql
type MonthlyFlux {
  input: Float! 
  output: Float! 
}

type YearlyFlux {
  year: Int!              
  fluxFinancier: FluxByMonth! 
}

type FluxByMonth {
  jan: MonthlyFlux
  fev: MonthlyFlux
  mars: MonthlyFlux
  avr: MonthlyFlux
  mai: MonthlyFlux
  juin: MonthlyFlux
  juil: MonthlyFlux
  aout: MonthlyFlux
  sept: MonthlyFlux
  oct: MonthlyFlux
  nov: MonthlyFlux
  dec: MonthlyFlux
}
`;

const query = `#graphql
  getYearBilan(year: Int): YearlyFlux!
`;
export default { typeDef, query };
