const app = require('./app');
const { connectDB } = require('./config/db');
const env = require('./config/env');

async function start() {
  await connectDB(env.mongoUri);
  app.listen(env.port, '0.0.0.0', () => {
    console.log(`API escuchando en el puerto ${env.port} (${env.nodeEnv})`);
  });
}

start().catch((error) => {
  console.error('No se pudo iniciar la API:', error);
  process.exit(1);
});
