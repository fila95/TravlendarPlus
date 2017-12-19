const express = require('express')
const auth = require('../auth')
const router = express.Router()

router.use('/api/v1/login', require('./login').router)
router.use('/api/v1/settings', auth, require('./settings').router)
router.use('/api/v1/calendars', auth, require('./calendars').router)
router.use('/api/v1/calendars/:calendar_id/events', auth, require('./events').router)
router.use('/api/v1/schedule', auth, require('./schedule').router)
router.use('/api/v1/pushNotificationToken', auth, require('./pushNotificationToken').router)
module.exports = router