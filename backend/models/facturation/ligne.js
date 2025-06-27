export const verifyLigneHasInterval = ({ ligne }) => {
    let prixRecalcule = 0;
    // Si aucun tarif n'existe, prendre le prix du service
    if (ligne.service.tarif==undefined || ligne.service.tarif.length === 0) {
        prixRecalcule = ligne.service.prix || 0; // Si prix est undefined, mettre 0
    } else {
        // Chercher le tarif correspondant à la quantité
        const tarif = ligne.service.tarif.find((tarif) => {
            if (tarif.maxQuantity == null) {
                return ligne.quantite >= tarif.minQuantity;
            }
            return (
                ligne.quantite >= tarif.minQuantity &&
                ligne.quantite <= tarif.maxQuantity
            );
        });

        if (!tarif) {
            throw new Error(`Le service \"${ligne.service.libelle}\" n'est pas configué pour ${ligne.quantite} ${ligne.unit}`);

        }
        prixRecalcule = tarif.prix || 0;
    }
    if (prixRecalcule == 0) {
                     throw new Error(`Le prix du service \"${ligne.service.libelle}\" semble être 0`);

    }
};
