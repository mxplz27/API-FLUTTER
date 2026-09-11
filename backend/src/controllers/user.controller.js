const User = require('../models/User');
const HttpError = require('../utils/httpError');
const { requireFields } = require('../utils/validate');

const EDITABLE_FIELDS = ['fullName', 'email', 'phone', 'role', 'office'];

async function findCurrentUser(req, projection = '') {
  const user = await User.findById(req.userId).select(projection);
  if (!user) throw new HttpError(401, 'La cuenta ya no existe');
  return user;
}

// GET /api/users/me
async function getMe(req, res) {
  res.json(await findCurrentUser(req));
}

// PUT /api/users/me
async function updateMe(req, res) {
  const body = req.body ?? {};
  const user = await findCurrentUser(req);

  for (const field of EDITABLE_FIELDS) {
    if (body[field] !== undefined) user[field] = body[field];
  }
  await user.save();

  res.json(user);
}

// PUT /api/users/me/password
async function changePassword(req, res) {
  const body = req.body ?? {};
  requireFields(body, ['currentPassword', 'newPassword']);

  const user = await findCurrentUser(req, '+password');
  if (!(await user.comparePassword(body.currentPassword))) {
    // 400 y no 401: la sesión sigue siendo válida, solo falló la verificación.
    throw new HttpError(400, 'La contraseña actual no es correcta');
  }
  if (body.currentPassword === body.newPassword) {
    throw new HttpError(400, 'Debe ser distinta a la contraseña actual');
  }

  user.password = body.newPassword;
  await user.save();

  res.json({ message: 'Contraseña actualizada correctamente' });
}

module.exports = { getMe, updateMe, changePassword };
