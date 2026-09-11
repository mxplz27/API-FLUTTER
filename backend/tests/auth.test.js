const assert = require('node:assert/strict');
const { after, before, describe, it } = require('node:test');

const mailer = require('../src/utils/mailer');
const { app, request, connectTestDB, disconnectTestDB, registerUser } = require('./helpers');

before(connectTestDB);
after(disconnectTestDB);

describe('POST /api/auth/register', () => {
  it('crea la cuenta y devuelve token sin exponer la contraseña', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        fullName: 'Ana Martínez',
        email: 'Ana@Inmobiliaria.com',
        phone: '3001234567',
        password: 'secreta123',
      })
      .expect(201);

    assert.ok(res.body.token);
    assert.equal(res.body.user.email, 'ana@inmobiliaria.com');
    assert.equal(res.body.user.role, 'Asesor inmobiliario');
    assert.ok(res.body.user.id);
    assert.equal(res.body.user.password, undefined);
  });

  it('rechaza un correo ya registrado', async () => {
    const { user } = await registerUser();
    const res = await request(app)
      .post('/api/auth/register')
      .send({ fullName: 'Otro', email: user.email, phone: '1', password: 'secreta123' })
      .expect(409);
    assert.equal(res.body.message, 'El correo ya está registrado');
  });

  it('valida campos obligatorios y longitud de la contraseña', async () => {
    await request(app).post('/api/auth/register').send({ email: 'x@test.com' }).expect(400);
    const res = await request(app)
      .post('/api/auth/register')
      .send({ fullName: 'Corta', email: 'corta@test.com', phone: '1', password: '123' })
      .expect(400);
    assert.match(res.body.message, /mínimo 6/);
  });
});

describe('POST /api/auth/login', () => {
  it('inicia sesión con credenciales válidas', async () => {
    const { user, password } = await registerUser();
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: user.email.toUpperCase(), password })
      .expect(200);
    assert.ok(res.body.token);
    assert.equal(res.body.user.id, user.id);
  });

  it('rechaza una contraseña incorrecta', async () => {
    const { user } = await registerUser();
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: user.email, password: 'incorrecta' })
      .expect(401);
    assert.equal(res.body.message, 'Correo o contraseña incorrectos');
  });
});

describe('Recuperación de contraseña', () => {
  it('envía un código y permite restablecer la contraseña con él', async () => {
    const { user } = await registerUser();
    let sentCode;
    const original = mailer.sendResetCode;
    mailer.sendResetCode = async (_email, code) => {
      sentCode = code;
    };

    try {
      await request(app).post('/api/auth/forgot-password').send({ email: user.email }).expect(200);
    } finally {
      mailer.sendResetCode = original;
    }
    assert.match(sentCode, /^\d{6}$/);

    await request(app)
      .post('/api/auth/reset-password')
      .send({ email: user.email, code: '000000', password: 'nueva1234' })
      .expect(400);

    await request(app)
      .post('/api/auth/reset-password')
      .send({ email: user.email, code: sentCode, password: 'nueva1234' })
      .expect(200);

    await request(app)
      .post('/api/auth/login')
      .send({ email: user.email, password: 'nueva1234' })
      .expect(200);

    // El código es de un solo uso.
    await request(app)
      .post('/api/auth/reset-password')
      .send({ email: user.email, code: sentCode, password: 'otra12345' })
      .expect(400);
  });

  it('no revela si el correo existe', async () => {
    const res = await request(app)
      .post('/api/auth/forgot-password')
      .send({ email: 'noexiste@test.com' })
      .expect(200);
    assert.match(res.body.message, /Si el correo está registrado/);
  });
});

describe('Perfil /api/users/me', () => {
  it('exige token', async () => {
    await request(app).get('/api/users/me').expect(401);
    await request(app).get('/api/users/me').set('Authorization', 'Bearer malo').expect(401);
  });

  it('consulta y actualiza el perfil', async () => {
    const { token, user } = await registerUser();
    const auth = { Authorization: `Bearer ${token}` };

    const me = await request(app).get('/api/users/me').set(auth).expect(200);
    assert.equal(me.body.email, user.email);

    const updated = await request(app)
      .put('/api/users/me')
      .set(auth)
      .send({ fullName: 'Laura Ospina', office: 'Oficina Norte' })
      .expect(200);
    assert.equal(updated.body.fullName, 'Laura Ospina');
    assert.equal(updated.body.office, 'Oficina Norte');
  });

  it('cambia la contraseña validando la actual', async () => {
    const { token, user, password } = await registerUser();
    const auth = { Authorization: `Bearer ${token}` };

    const wrong = await request(app)
      .put('/api/users/me/password')
      .set(auth)
      .send({ currentPassword: 'incorrecta', newPassword: 'nueva1234' })
      .expect(400);
    assert.equal(wrong.body.message, 'La contraseña actual no es correcta');

    await request(app)
      .put('/api/users/me/password')
      .set(auth)
      .send({ currentPassword: password, newPassword: 'nueva1234' })
      .expect(200);

    await request(app)
      .post('/api/auth/login')
      .send({ email: user.email, password: 'nueva1234' })
      .expect(200);
  });
});
