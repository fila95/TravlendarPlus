var validate = require('uuid-validate');
const express = require('express')
const crypto = require('crypto')
const router = express.Router()

let generateToken = () => {
	return crypto.randomBytes(48).toString('base64')
}

// Create settings in the database for the user user
let createSettings = (user, req, cb) => {
	req.models.settings.create({}, (err, settings) => {
		user.setSettings(settings, cb)
	})
}

// Create a device in the database for the user user and
// return an object containing the access token
let createDevice = (user, req, cb) => {
	let access_token = generateToken()
	req.models.devices.create({
		user_id: user.id,
		access_token: access_token,
		device_type: req.body.device_type || null
	}, cb)
}

router.post('/login', function (req, res) {
	if (!req.body.user_token) {
		return res.sendStatus(401).end()
	}

	req.models.users.find({ user_token: req.body.user_token }, (err, users) => {
		// No users exists with that user_token => create it
		if (users.length == 0) {
			// Check if it's a valid UUID
			if (!validate(req.body.user_token, 4)) {
				return res.sendStatus(403).end()
			}
			// Create the user and the device
			req.models.users.create({
				user_token: req.body.user_token
			}, (err, user) => {
				createDevice(user, req, (err, device) => {
					createSettings(user, req, (err, settings) => {
						res.json({ access_token: device.access_token }).end()
					})
				})
			})
		} else {
			// The user already exists, just create the device
			createDevice(users[0], req, (err, device) => {
				res.json({ access_token: device.access_token }).end()
			})
		}
	})

})

module.exports = router