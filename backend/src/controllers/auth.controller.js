const crypto = require('crypto');

const { signToken } = require('../middleware/auth');
const User = require('../models/User');
const HttpError = require('../utils/httpError');
const mailer = require('../utils/mailer');
const { requireFields } = require('../utils/validate');

const RESET_CODE_TTL_MS = 15 * 60 * 1000;
const MAX_RESET_ATTEMPTS = 5;

const hashCode = (code) => crypto.createHash('sha256').update(code).digest('hex');

// POST /api/auth/register
async function register(req, res) {
  const body = req.body ?? {};
  requireFields(body, ['fullName', 'email', 'phone', 'password']);

  const exists = await User.exists({ email: body.email.trim().toLowerCase() });
  if (exists) throw new HttpError(409, 'El correo ya está registrado');

  const user = await User.create({
    fullName: body.fullName,
    email: body.email,
    phone: body.phone,
    password: body.password,
  });

  res.status(201).json({ token: signToken(user._id), user });
}

// POST /api/auth/login
async function login(req, res) {
  const body = req.body ?? {};
  requireFields(body, ['email', 'password']);

  const user = await User.findOne({ email: body.email.trim().toLowerCase() }).select('+password');
  if (!user || !(await user.comparePassword(body.password))) {
    throw new HttpError(401, 'Correo o contraseña incorrectos');
  }

  res.json({ token: signToken(user._id), user });
}

// POST /api/auth/forgot-password
// Responde igual exista o no el correo para no revelar qué cuentas existen.
async function forgotPassword(req, res) {
  const body = req.body ?? {};
  requireFields(body, ['email']);

  const user = await User.findOne({ email: body.email.trim().toLowerCase() });
  if (user) {
    const code = crypto.randomInt(100000, 1000000).toString();
    user.resetCodeHash = hashCode(code);
    user.resetCodeExpires = new Date(Date.now() + RESET_CODE_TTL_MS);
    user.resetAttempts = 0;
    await user.save();
    await mailer.sendResetCode(user.email, code);
  }

  res.json({
    message: 'Si el correo está registrado, recibirás un código de recuperación.',
  });
}

// POST /api/auth/reset-password
async function resetPassword(req, res) {
  const body = req.body ?? {};
  requireFields(body, ['email', 'code', 'password']);

  const user = await User.findOne({ email: body.email.trim().toLowerCase() }).select(
    '+resetCodeHash +resetCodeExpires +resetAttempts',
  );
  const invalid = new HttpError(400, 'El código no es válido o ya venció');

  if (!user || !user.resetCodeHash || user.resetCodeExpires < new Date()) throw invalid;

  if (user.resetAttempts >= MAX_RESET_ATTEMPTS) {
    throw new HttpError(429, 'Demasiados intentos. Solicita un código nuevo.');
  }

  if (hashCode(body.code.trim()) !== user.resetCodeHash) {
    user.resetAttempts += 1;
    await user.save();
    throw invalid;
  }

  user.password = body.password;
  user.resetCodeHash = undefined;
  user.resetCodeExpires = undefined;
  user.resetAttempts = 0;
  await user.save();

  res.json({ message: 'Contraseña restablecida. Ya puedes iniciar sesión.' });
}

module.exports = { register, login, forgotPassword, resetPassword };
