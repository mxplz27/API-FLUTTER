const { Router } = require('express');

const tasks = require('../controllers/task.controller');
const { requireAuth } = require('../middleware/auth');

const router = Router();

router.use(requireAuth);
router.get('/', tasks.listTasks);
router.post('/', tasks.createTask);
router.get('/:id', tasks.getTask);
router.put('/:id', tasks.updateTask);
router.patch('/:id/status', tasks.updateTaskStatus);
router.delete('/:id', tasks.deleteTask);

module.exports = router;
