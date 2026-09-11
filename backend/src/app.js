const cors = require('cors');
const express = require('express');

const env = require('./config/env');
const { errorHandler, notFound } = require('./middleware/errorHandler');
const authRoutes = require('./routes/auth.routes');
const taskRoutes = require('./routes/task.routes');
const userRoutes = require('./routes/user.routes');

const app = express();

app.use(
  cors({
    origin: env.corsOrigin === '*' ? '*' : env.corsOrigin.split(',').map((o) => o.trim()),
  }),
);
app.use(express.json({ limit: '100kb' }));

app.get('/', (_req, res) => {
  res.json({ name: 'Gestor Inmobiliario API', version: '1.0.0', health: '/api/health' });
});
app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/tasks', taskRoutes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;
