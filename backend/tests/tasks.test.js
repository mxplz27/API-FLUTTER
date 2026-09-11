const assert = require('node:assert/strict');
const { after, before, describe, it } = require('node:test');

const { app, request, connectTestDB, disconnectTestDB, registerUser } = require('./helpers');

before(connectTestDB);
after(disconnectTestDB);

const sampleTask = (overrides = {}) => ({
  title: 'Visita con familia Gómez',
  client: 'María Gómez',
  property: 'Apartamento Torre Vista 802',
  dateTime: '2026-09-15T15:30:00.000Z',
  type: 'visit',
  notes: 'Confirmar parqueadero',
  ...overrides,
});

describe('CRUD /api/tasks', () => {
  it('exige autenticación', async () => {
    await request(app).get('/api/tasks').expect(401);
    await request(app).post('/api/tasks').send(sampleTask()).expect(401);
  });

  it('crea, lista, consulta, actualiza y elimina tareas', async () => {
    const { token } = await registerUser();
    const auth = { Authorization: `Bearer ${token}` };

    const created = await request(app).post('/api/tasks').set(auth).send(sampleTask()).expect(201);
    assert.ok(created.body.id);
    assert.equal(created.body.status, 'pending');
    assert.equal(created.body.dateTime, '2026-09-15T15:30:00.000Z');

    await request(app)
      .post('/api/tasks')
      .set(auth)
      .send(sampleTask({ title: 'Firma', type: 'signing', dateTime: '2026-09-10T14:00:00.000Z' }))
      .expect(201);

    const list = await request(app).get('/api/tasks').set(auth).expect(200);
    assert.equal(list.body.length, 2);
    assert.equal(list.body[0].title, 'Firma', 'ordenadas por fecha ascendente');

    const id = created.body.id;
    const one = await request(app).get(`/api/tasks/${id}`).set(auth).expect(200);
    assert.equal(one.body.client, 'María Gómez');

    const updated = await request(app)
      .put(`/api/tasks/${id}`)
      .set(auth)
      .send({ title: 'Visita reprogramada', status: 'done' })
      .expect(200);
    assert.equal(updated.body.title, 'Visita reprogramada');
    assert.equal(updated.body.client, 'María Gómez', 'conserva los campos no enviados');

    const patched = await request(app)
      .patch(`/api/tasks/${id}/status`)
      .set(auth)
      .send({ status: 'cancelled' })
      .expect(200);
    assert.equal(patched.body.status, 'cancelled');

    const pending = await request(app).get('/api/tasks?status=pending').set(auth).expect(200);
    assert.equal(pending.body.length, 1);

    await request(app).delete(`/api/tasks/${id}`).set(auth).expect(204);
    await request(app).get(`/api/tasks/${id}`).set(auth).expect(404);
  });

  it('valida los datos de la tarea', async () => {
    const { token } = await registerUser();
    const auth = { Authorization: `Bearer ${token}` };

    const missing = await request(app)
      .post('/api/tasks')
      .set(auth)
      .send(sampleTask({ title: '' }))
      .expect(400);
    assert.equal(missing.body.message, 'El título es obligatorio');

    await request(app).post('/api/tasks').set(auth).send(sampleTask({ type: 'otro' })).expect(400);
    await request(app).post('/api/tasks').set(auth).send(sampleTask({ dateTime: 'mañana' })).expect(400);

    const created = await request(app).post('/api/tasks').set(auth).send(sampleTask()).expect(201);
    await request(app).patch(`/api/tasks/${created.body.id}/status`).set(auth).send({}).expect(400);
    await request(app).get('/api/tasks/no-es-un-id').set(auth).expect(404);
  });

  it('cada usuario solo ve y modifica sus propias tareas', async () => {
    const owner = await registerUser();
    const intruder = await registerUser();

    const created = await request(app)
      .post('/api/tasks')
      .set({ Authorization: `Bearer ${owner.token}` })
      .send(sampleTask())
      .expect(201);

    const intruderAuth = { Authorization: `Bearer ${intruder.token}` };
    const list = await request(app).get('/api/tasks').set(intruderAuth).expect(200);
    assert.equal(list.body.length, 0);

    await request(app).get(`/api/tasks/${created.body.id}`).set(intruderAuth).expect(404);
    await request(app).put(`/api/tasks/${created.body.id}`).set(intruderAuth).send({ title: 'x' }).expect(404);
    await request(app).delete(`/api/tasks/${created.body.id}`).set(intruderAuth).expect(404);
  });
});
