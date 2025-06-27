class Utils{
    calculerMontantTotal({
    lignes,
    reduction,
    tva,
    tauxTVA,
  }) {
    let sommeApresRemise = 0;
    let fraisDivers = 0;
      lignes.forEach((ligneFacture) => {
      sommeApresRemise += ligneFacture.montant;
      if (ligneFacture.fraisDivers.length > 0) {
        ligneFacture.fraisDivers.forEach((frais) => {
          if (frais.tva) {
            fraisDivers += frais.montant * (1 + tauxTVA / 100);
          } else {
            fraisDivers += frais.montant;
          }
        });
      }
    });
    const montantApresreduction = sommeApresRemise - this.reduction({lignes:lignes, reduction:reduction, }) ;
    
    function montantTotalAvecTVA(montant) {
      return montant * (1 + tauxTVA / 100);
    }
    const montantSansFrais = tva
      ? montantTotalAvecTVA(montantApresreduction)
      : montantApresreduction;

    return montantSansFrais + fraisDivers;
  }

  reduction = ({ lignes, reduction }) => {
    let montantLignes = 0;
    if (reduction.unite === "%") {
     lignes.forEach((ligneFacture) => {
      montantLignes += ligneFacture.montant;
    });
      return montantLignes * reduction.valeur / 100;
    } 
    return reduction.valeur ?? 0;
  }
  
}

export default Utils;

export const StatusFacture = {
  paid: "paid",
  unpaid: "unpaid",
  tobepaid: "tobepaid",
  blocked: "blocked",
  partialpaid: "partialpaid",
};