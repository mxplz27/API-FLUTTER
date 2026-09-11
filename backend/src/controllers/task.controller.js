const mongoose = require('mongoose');

const Task = require('../models/Task');
const HttpError = require('../utils/httpError');

const EDITABLE_FIELDS = ['title', 'client', 'property', 'dateTime', 'type', 'status', 'notes'];

function pickEditable(body) {
  const data = {};
  for (const field of EDITABLE_FIELDS) {
    if (body[field] !== undefined) data[field] = body[field];
  }
  return data;
}

// Busca la tarea solo entre las del usuario autenticado.
async function findOwnTask(req) {
  const { id } = req.params;
  const task = mongoose.isValidObjectId(id)
    ? await Task.findOne({ _id: id, owner: req.userId })
    : null;
  if (!task) throw new HttpError(404, 'Tarea no encontrada');
  return task;
}

// GET /api/tasks?status=pending&from=2026-09-01&to=2026-09-30
async function listTasks(req, res) {
  const filter = { owner: req.userId };
  const { status, from, to } = req.query;

  if (status) {
    if (!Task.TASK_STATUSES.includes(status)) throw new HttpError(400, 'Estado inválido');
    filter.status = status;
  }
  if (from || to) {
    filter.dateTime = {};
    if (from) filter.dateTime.$gte = new Date(from);
    if (to) filter.dateTime.$lte = new Date(to);
    if (Object.values(filter.dateTime).some((date) => Number.isNaN(date.getTime()))) {
      throw new HttpError(400, 'Rango de fechas inválido');
    }
  }

  res.json(await Task.find(filter).sort({ dateTime: 1 }));
}

// POST /api/tasks
async function createTask(req, res) {
  const task = await Task.create({ ...pickEditable(req.body ?? {}), owner: req.userId });
  res.status(201).json(task);
}

// GET /api/tasks/:id
async function getTask(req, res) {
  res.json(await findOwnTask(req));
}

// PUT /api/tasks/:id
async function updateTask(req, res) {
  const task = await findOwnTask(req);
  task.set(pickEditable(req.body ?? {}));
  await task.save();
  res.json(task);
}

// PATCH /api/tasks/:id/status
async function updateTaskStatus(req, res) {
  const status = req.body?.status;
  if (!Task.TASK_STATUSES.includes(status)) throw new HttpError(400, 'Estado inválido');

  const task = await findOwnTask(req);
  task.status = status;
  await task.save();
  res.json(task);
}

// DELETE /api/tasks/:id
async function deleteTask(req, res) {
  const task = await findOwnTask(req);
  await task.deleteOne();
  res.status(204).end();
}

module.exports = { listTasks, createTask, getTask, updateTask, updateTaskStatus, deleteTask };
