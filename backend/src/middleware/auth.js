const jwt = require('jsonwebtoken');

const env = require('../config/env');
const HttpError = require('../utils/httpError');

// Exige un header "Authorization: Bearer <token>" válido y deja el id del
// usuario en req.userId.
function requireAuth(req, _res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return next(new HttpError(401, 'Debes iniciar sesión'));
  }

  try {
    const payload = jwt.verify(token, env.jwtSecret);
    req.userId = payload.sub;
    return next();
  } catch {
    return next(new HttpError(401, 'La sesión expiró o no es válida'));
  }
}

function signToken(userId) {
  return jwt.sign({ sub: userId.toString() }, env.jwtSecret, {
    expiresIn: env.jwtExpiresIn,
  });
}

module.exports = { requireAuth, signToken };
