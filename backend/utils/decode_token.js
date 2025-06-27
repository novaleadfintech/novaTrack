const getUserFromToken = (context) => {
  if (!context.user) {
    throw new Error('Authentification requise');
  }
  return context.user.user;
};

export default getUserFromToken;
