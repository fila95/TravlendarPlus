const express = require('express')
const router = express.Router()

router.patch('/', (req, res) => {
	if (!req.body.lat || !req.body.lng) {
		return res.sendStatus(400).end()
	}
	req.user.last_known_position_lat = req.body.lat
	req.user.last_known_position_lng = req.body.lng
	req.user.save((err) => {
		if (err) return res.status(500).end()
		return res.status(204).end()
	})
})

module.exports = {
	router: router
}