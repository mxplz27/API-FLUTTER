const nodemailer = require('nodemailer');

const env = require('../config/env');

const transporter = env.smtp.host
  ? nodemailer.createTransport({
      host: env.smtp.host,
      port: env.smtp.port,
      secure: env.smtp.port === 465,
      auth: { user: env.smtp.user, pass: env.smtp.pass },
    })
  : null;

// Envía el código de recuperación. Sin SMTP configurado lo escribe en los
// logs del servidor para poder probar el flujo en desarrollo.
async function sendResetCode(email, code) {
  if (!transporter) {
    console.log(`[recuperación] Código para ${email}: ${code}`);
    return;
  }

  await transporter.sendMail({
    from: env.smtp.from,
    to: email,
    subject: 'Código para restablecer tu contraseña',
    text:
      `Tu código de recuperación es ${code}.\n` +
      'Vence en 15 minutos. Si no lo solicitaste, ignora este correo.',
  });
}

module.exports = { sendResetCode };
