const express = require('express')
const auth = require('../auth')
const router = express.Router()

/*app.get("/hello", (req, res) => {
	res.end("hello")
})

app.get("/helloWithAuth", (req, res) => {
	res.json(req.user)
	res.end()
})*/

router.use('/api/v1/', require('./login'))
router.use('/api/v1/calendars', auth, require('./calendars'))
router.use('/api/v1/calendars/:calendar_id/events', auth, require('./events'))

module.exports = router