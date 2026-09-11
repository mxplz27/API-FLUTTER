const HttpError = require('./httpError');

// Lanza 400 si alguno de los campos no es un texto con contenido.
function requireFields(body, fields) {
  for (const field of fields) {
    if (typeof body[field] !== 'string' || body[field].trim() === '') {
      throw new HttpError(400, `El campo "${field}" es obligatorio`);
    }
  }
}

module.exports = { requireFields };
