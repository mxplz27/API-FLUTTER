require('dotenv').config({ quiet: true });

const nodeEnv = process.env.NODE_ENV || 'development';
const isProduction = nodeEnv === 'production';

// Railway expone la cadena de su plugin de MongoDB como MONGO_URL.
const mongoUri =
  process.env.MONGODB_URI ||
  process.env.MONGO_URL ||
  'mongodb://127.0.0.1:27017/gestor_inmobiliario';

if (isProduction && !process.env.JWT_SECRET) {
  throw new Error('JWT_SECRET es obligatorio en producción.');
}

module.exports = {
  nodeEnv,
  isProduction,
  port: Number(process.env.PORT) || 3000,
  mongoUri,
  jwtSecret: process.env.JWT_SECRET || 'dev-secret-no-usar-en-produccion',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  // Lista separada por comas; "*" permite cualquier origen.
  corsOrigin: process.env.CORS_ORIGIN || '*',
  smtp: {
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT) || 587,
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
    from: process.env.SMTP_FROM || process.env.SMTP_USER,
  },
};
