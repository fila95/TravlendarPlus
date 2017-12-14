const express = require('express')
const auth = require('../auth')
const router = express.Router()

router.use('/api/v1/login', require('./login'))
router.use('/api/v1/settings', auth, require('./settings'))
router.use('/api/v1/calendars', auth, require('./calendars'))
router.use('/api/v1/calendars/:calendar_id/events', auth, require('./events'))
router.use('/api/v1/schedule', auth, require('./schedule'))
router.use('/api/v1/pushNotificationToken', auth, require('./pushNotificationToken'))
module.exports = router