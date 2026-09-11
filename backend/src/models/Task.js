const mongoose = require('mongoose');

// Deben coincidir con los enums AppointmentType y AppointmentStatus de Flutter.
const TASK_TYPES = ['visit', 'signing', 'call', 'appraisal'];
const TASK_STATUSES = ['pending', 'done', 'cancelled'];

const taskSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: [true, 'El título es obligatorio'],
      trim: true,
      maxlength: [120, 'El título no puede superar 120 caracteres'],
    },
    client: {
      type: String,
      required: [true, 'El cliente es obligatorio'],
      trim: true,
    },
    property: {
      type: String,
      required: [true, 'La propiedad es obligatoria'],
      trim: true,
    },
    dateTime: {
      type: Date,
      required: [true, 'La fecha y hora son obligatorias'],
    },
    type: {
      type: String,
      enum: { values: TASK_TYPES, message: 'Tipo de gestión inválido' },
      default: 'visit',
    },
    status: {
      type: String,
      enum: { values: TASK_STATUSES, message: 'Estado inválido' },
      default: 'pending',
    },
    notes: { type: String, trim: true, default: '' },
  },
  {
    timestamps: true,
    toJSON: {
      transform(_doc, ret) {
        ret.id = ret._id.toString();
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  },
);

module.exports = mongoose.model('Task', taskSchema);
module.exports.TASK_TYPES = TASK_TYPES;
module.exports.TASK_STATUSES = TASK_STATUSES;
