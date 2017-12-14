const express = require('express')
const router = express.Router()

router.put('/', (req, res) => {
	if (!req.body.token) {
		return res.sendStatus(400).end()
	}
	req.models.devices.find({ access_token: req.get('X-Access-Token') }).first((err, device) => {
		device.push_token = req.body.token
		device.save(() => {
			return res.status(204).end()
		})
	})
})

module.exports = router