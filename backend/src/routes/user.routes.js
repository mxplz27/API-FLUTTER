const { Router } = require('express');

const users = require('../controllers/user.controller');
const { requireAuth } = require('../middleware/auth');

const router = Router();

router.use(requireAuth);
router.get('/me', users.getMe);
router.put('/me', users.updateMe);
router.put('/me/password', users.changePassword);

module.exports = router;
