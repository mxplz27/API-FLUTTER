const mongoose = require('mongoose');

const HttpError = require('../utils/httpError');

function notFound(req, _res, next) {
  next(new HttpError(404, `Ruta no encontrada: ${req.method} ${req.originalUrl}`));
}

// Express reconoce el manejador de errores por sus 4 parámetros.
// eslint-disable-next-line no-unused-vars
function errorHandler(err, _req, res, _next) {
  if (err instanceof HttpError) {
    return res.status(err.status).json({ message: err.message });
  }

  if (err instanceof mongoose.Error.ValidationError) {
    const first = Object.values(err.errors)[0];
    return res.status(400).json({ message: first.message });
  }

  if (err instanceof mongoose.Error.CastError) {
    return res.status(400).json({ message: `Valor inválido para ${err.path}` });
  }

  if (err.code === 11000) {
    return res.status(409).json({ message: 'El correo ya está registrado' });
  }

  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ message: 'El cuerpo de la petición no es JSON válido' });
  }

  console.error(err);
  return res.status(500).json({ message: 'Error interno del servidor' });
}

module.exports = { notFound, errorHandler };
