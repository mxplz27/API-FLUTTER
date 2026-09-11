const mongoose = require('mongoose');
const request = require('supertest');

const app = require('../src/app');

const TEST_DB_URI =
  process.env.MONGODB_URI_TEST || 'mongodb://127.0.0.1:27017/gestor_inmobiliario_test';

async function connectTestDB() {
  await mongoose.connect(TEST_DB_URI);
  await mongoose.connection.dropDatabase();
}

async function disconnectTestDB() {
  await mongoose.connection.dropDatabase();
  await mongoose.disconnect();
}

let counter = 0;

// Registra un usuario nuevo y devuelve { token, user, password }.
async function registerUser(overrides = {}) {
  counter += 1;
  const payload = {
    fullName: 'Asesor de Prueba',
    email: `asesor${counter}@test.com`,
    phone: '+57 300 000 0000',
    password: 'secreta123',
    ...overrides,
  };
  const res = await request(app).post('/api/auth/register').send(payload).expect(201);
  return { token: res.body.token, user: res.body.user, password: payload.password };
}

module.exports = { app, request, connectTestDB, disconnectTestDB, registerUser };
