const express = require('express')
const router = express.Router()

router.put('/', (req, res) => {
	if (!req.body.token) {
		return res.sendStatus(400).end()
	}
	if (!req.get('X-Access-Token')) {
		return res.sendStatus(401).end()
	}
	req.models.devices.find({ access_token: req.get('X-Access-Token') }).first((err, device) => {
		if (err || !device) {
			return res.sendStatus(403).end()
		}

		device.push_token = req.body.token
		device.save(() => {
			return res.status(204).end()
		})
	})
})

module.exports = router