const isValidEmail = ({ email }) => {
  //regex de l'email
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  const result = regex.test(email);
  if (!result) {
    throw new Error("Le format de l'email est invalide");
  }
};

const isValidValue = ({ value }) => {
  const checkValue = ({ val }) => {
    if (val !== undefined && val !== null) {
      if (
        (typeof val === "string" && val.trim().length === 0) ||
        (Array.isArray(val) && val.length === 0) ||
        // typeof val === "number" || //&& val === 0
        (typeof value === "object" && Object.keys(value).length === 0)
      ) {
        throw new Error("Verifiez les valeurs des champs et réessayez!");
      }
    } else {
      throw new Error("La valeur d'un champs obligatoire n'est pas fournie!");
    }
  };

  if (Array.isArray(value)) {
    return value.forEach((val) => checkValue({ val: val }));
  } else if (typeof value === "object") {
    return Object.values(value).forEach((val) => checkValue({ val: val }));
  } else {
    return checkValue({ val: value });
  }
};

export { isValidEmail, isValidValue };
