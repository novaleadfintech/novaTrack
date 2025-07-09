import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import Client, { EtatClient, NatureClient } from "../client/client.js";
import { isValidValue } from "../../utils/util.js";
const clientFacureGlobalValueCollection = db.collection(
  "clientFacureGlobalValues"
);
const clientModel = new Client();
class ClientFactureGlobaLValueModel {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await clientFacureGlobalValueCollection.exists())) {
      clientFacureGlobalValueCollection.create();
    }
  }
  clientFactureGlobalValues = async () => {
    // Récupérer toutes les valeurs configurées
    const query = await db.query(
      aql`FOR cfg IN ${clientFacureGlobalValueCollection} RETURN cfg`
    );
    const allValues = await query.all();

    // Transformer en Map : { clientId: nbreJrMaxPenalty }
    const valueMap = new Map();
    for (const item of allValues) {
      valueMap.set(item.clientId, item.nbreJrMaxPenalty);
    }

    // Récupérer tous les clients (avec tri et filtre si tu veux)
    const clients = await clientModel.getAllClients({
      etat: EtatClient.unarchived,
      nature: NatureClient.client,
    });

    const result = clients.map((client) => {
      const penalty = valueMap.get(client._id) ?? null;
      return {
        client,
        nbreJrMaxPenalty: penalty,
      };
    });
    return result;
  };

  clientFactureGlobalValueByClient = async ({ clientId }) => {
    if (!clientId) throw new Error("clientId requis");

    // Récupère la configuration spécifique pour ce client (si elle existe)
    const configQuery = await db.query(
      aql`FOR cfg IN ${clientFacureGlobalValueCollection} FILTER cfg.clientId == ${clientId} LIMIT 1 RETURN cfg`
    );
    const config = await configQuery.next();

    // Récupère les infos du client
    const client = await clientModel.getClient({ key: clientId });
    if (!client) throw new Error("Client introuvable");

    return config?.nbreJrMaxPenalty ?? null;
  };

  configClientFactureGlobaLValue = async ({ clientId, nbreJrMaxPenalty }) => {
    isValidValue({ value: { clientId, nbreJrMaxPenalty } });
    console.log("nbreJrMaxPenalty", nbreJrMaxPenalty);
    // Vérifie que le client existe
    await clientModel.isExistClient({
      key: clientId,
    });

    // Vérifie si une config existe déjà pour ce client
    const query = await db.query(aql`
      FOR cfg IN ${clientFacureGlobalValueCollection}
      FILTER cfg.clientId == ${clientId}
      LIMIT 1
      RETURN cfg
    `);

    if (query.hasNext) {
      const exist = await query.next();
      console.log(
        "maintenant c'est" +
          exist._key +
          " et nbreJrMaxPenalty: " +
          exist.nbreJrMaxPenalty
      );

      // Mise à jour
      await clientFacureGlobalValueCollection.update(exist._key, {
        nbreJrMaxPenalty: nbreJrMaxPenalty,
      });
      console.log("mise à jour effectuée" + nbreJrMaxPenalty);
    } else {
      // Création
      await clientFacureGlobalValueCollection.save({
        clientId: clientId,
        nbreJrMaxPenalty: nbreJrMaxPenalty,
      });
    }
    return "OK";
  };
}

export default ClientFactureGlobaLValueModel;
