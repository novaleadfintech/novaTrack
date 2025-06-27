import FormData from "form-data";
import Mailgun from "mailgun.js";

export const sendRoleAssignmentEmail = async ({
  personnel,
  user,
  role,
  password,
}) => {
  const htmlMessage = `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Informations de Connexion</title>
    <style>
        .footer {
            position: absolute;
            bottom: 20px;
            right: 20px;
            text-align: right;
            font-size: 14px;
            color: #333;
        }
    </style>
</head>
<body style="position: relative; padding-bottom: 40px;"> 
    <p>Bonjour <strong>${personnel.prenom} ${personnel.nom}</strong>,</p>

    <p>Vous avez été défini comme <strong>${role.libelle} dans le système de gestion de NOVA LEAD</strong>. Voici vos informations de connexion :</p>

    <ul>
        <li><strong>Identifiant</strong> : ${user.login}</li>
        <li><strong>Mot de passe</strong> : ${password}</li>
    </ul>

    <p>La modification de ce mot de passe est toujours possible. <a href=${process.env.WEB_URL} target="_blank">Cliquez ici</a> pour vous connecter à la version web</p>

    <div class="footer">
        <p>Cordialement,<br>L'équipe</p>
    </div>
</body>
</html>`;

  const mailgun = new Mailgun(FormData);
  const mg = mailgun.client({
    username: "api",
    key: process.env.EMAIL_API_KEY,
    // url: process.env.EMAIL_URL,
  });
  try {
    const data = await mg.messages.create(process.env.EMAIL_SOUS_DOMAIME, {
      from: `NOVALEAD <${process.env.EMAIL_FROM}>`,
      to: personnel.email,
      subject: `Informations de connexion`,
      html: htmlMessage,
    });
    return data;
  } catch (error) {
    console.log(error);
  }
};

export const stopServiceEmail = async ({ facture }) => {
  const services = facture.ligneFactures.map((l) => l.service.libelle);
  let servicesHtml = "";

  if (services.length === 1) {
    servicesHtml = `<p>Nous vous prions de bien vouloir procéder à la suspension du service <strong>${
      services[0]
    }</strong> de ${
      facture.client.raisonSociale ??
      facture.client.nom + " " + facture.client.prenom
    }.</p>`;
  } else {
    const lastService = services.pop();
    const listItems = services.map((s) => `<li>${s}</li>`).join("");
    servicesHtml = `
    <p>Nous vous prions de bien vouloir procéder à la suspension des services suivants de ${
      facture.client.raisonSociale ??
      facture.client.nom + " " + facture.client.prenom
    } :</p>
    <ul>
      ${listItems}
      <li>${lastService}</li>
    </ul>
  `;
  }

  const htmlMessage = `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Informations de Connexion</title>
    <style>
        .footer {
            position: absolute;
            bottom: 20px;
            right: 20px;
            text-align: right;
            font-size: 14px;
            color: #333;
        }
    </style>
</head>
<body style="position: relative; padding-bottom: 40px;"> 
    <p>Bonjour <strong>NOVALEAD</strong>,</p>
    ${servicesHtml}
    <div class="footer">
        <p>Cordialement,<br>L'équipe</p>
    </div>
</body>
</html>`;

  const mailgun = new Mailgun(FormData);
  const mg = mailgun.client({
    username: "api",
    key: process.env.EMAIL_API_KEY,
    // url: process.env.EMAIL_URL,
  });
  try {
    const data = await mg.messages.create(process.env.EMAIL_SOUS_DOMAIME, {
      from: `NOVALEAD <${process.env.EMAIL_FROM}>`,
      to: process.env.EMAIL_FROM,
      subject: `Demande d'arrêt de service`,
      html: htmlMessage,
    });

    return data;
  } catch (error) {
    console.log(error);
  }
};

export const reccurentInvoiceReadyEmail = async ({ facture }) => {
  const services = facture.ligneFactures.map((ligne) => ligne.service.libelle);

  let servicesText = "";
  if (services.length === 1) {
    servicesText = services[0];
  } else if (services.length === 2) {
    servicesText = services.join(" et ");
  } else {
    servicesText = `${services.slice(0, -1).join(", ")} et ${
      services[services.length - 1]
    }`;
  }

  const htmlMessage = `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        .footer {
            position: absolute;
            bottom: 20px;
            right: 20px;
            text-align: right;
            font-size: 14px;
            color: #333;
        }
    </style>
</head>
<body style="position: relative; padding-bottom: 40px;"> 
<p>Bonjour <strong>${
    facture.client.raisonSociale ??
    facture.client.nom + " " + facture.client.prenom
  }</strong>,</p>
    <p>Nous vous informons que votre facture liée ${
      services.length > 1 ? "aux services" : "au service"
    } <strong>${servicesText}</strong> est désormais disponible.</p>

    <ul>
        <li>Montant à payer : <strong>${facture.montant} FCFA</strong></li>
        <li>Date limite de paiement : <strong>${facture.datePayementEcheante.toLocaleDateString(
          "fr-FR",
          { day: "2-digit", month: "long", year: "numeric" }
        )} FCFA</strong></li>
        <li>Référence de la facture : <strong>${
          facture.reference
        } FCFA</strong></li>
    </ul>

    <p>
      Nous vous informons que vous devez effectuer le paiement au plus tard le <strong>[date d'échéance]</strong>.
    </p>
    <p>
      En cas de non-paiement, l'accès au service pourra être suspendu dans les jours suivants, conformément à nos conditions d'utilisation.
    </p>
    <p>
      La facture correspondante vous sera transmise dans les prochains jours.
    </p>
    <div class="footer">
        <p>Cordialement,<br>L'équipe</p>
    </div>
</body>
</html>`;
  const mailgun = new Mailgun(FormData);
  const mg = mailgun.client({
    username: "api",
    key: process.env.EMAIL_API_KEY,
    // url: process.env.EMAIL_URL,
  });
  try {
    const data = await mg.messages.create(process.env.EMAIL_SOUS_DOMAIME, {
      from: `NOVALEAD <${process.env.EMAIL_FROM}>`,
      to: facture.client.email,
      subject: `Nouvelle facture disponible`,
      html: htmlMessage,
    });

    return data;
  } catch (error) {
    console.log(error);
  }
};

export const sendresetLoginEmail = async ({ personnel, password }) => {
  const htmlMessage = `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Informations de Connexion</title>
    <style>
        .footer {
            position: absolute;
            bottom: 20px;
            right: 20px;
            text-align: right;
            font-size: 14px;
            color: #333;
        }
    </style>
</head>
<body style="position: relative; padding-bottom: 40px;"> 
    <p>Bonjour <strong>${personnel.prenom} ${personnel.nom}</strong>,</p>

    <p>Vos paramètres de connexion au système de gestion de NOVA LEAD ont été réinitialisé</strong>. Désormais voici vos paramètres de connexion :</p>

    <ul>
        <li><strong>Identifiant</strong> : ${personnel.email}</li>
        <li><strong>Mot de passe</strong> : ${password}</li>
    </ul>

    <p>Veuillez changer votre mot de passe après votre première connexion. <a href=${process.env.WEB_URL} target="_blank">Cliquez ici</a> pour vous connecter à la version web</p>

    <div class="footer">
        <p>Cordialement,<br>L'équipe</p>
    </div>
</body>
</html>`;

  const mailgun = new Mailgun(FormData);
  const mg = mailgun.client({
    username: "api",
    key: process.env.EMAIL_API_KEY,
    // url: process.env.EMAIL_URL,
  });
  try {
    const data = await mg.messages.create(process.env.EMAIL_SOUS_DOMAIME, {
      from: `NOVALEAD <${process.env.EMAIL_FROM}>`,
      to: personnel.email,
      subject: `Réinitialisation des paramètres de connexion`,
      html: htmlMessage,
    });

    return data;
  } catch (error) {
    console.log(error);
  }
};

// export const sendSimpleMessage = async () => {
//   const mailgun = new Mailgun(FormData);
//   const mg = mailgun.client({
//     username: "api",
//     key: process.env.EMAIL_API_KEY,
//     // url: process.env.EMAIL_URL,
//   });
//   try {
//     const data = await mg.messages.create("mg.novalead.dev", {
//       from: `NOVALEAD <${process.env.EMAIL_FROM}>`,
//       to: "ayawaetsiam2004@gmail.com",
//       subject: "Hello Komlatse Komla Dodji",

//       text: "Congratulations Komlatse Komla Dodji, you just sent an email with Mailgun! You are truly awesome!",
//     });

//     console.log(data);
//   } catch (error) {
//     console.log(error);
//   }
// };
