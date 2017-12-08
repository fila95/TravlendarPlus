const validate = require('uuid-validate');
const express = require('express')
const crypto = require('crypto')
const router = express.Router()

// Generate a valid access_token
let generateToken = () => {
	return crypto.randomBytes(48).toString('base64')
}

// Create an user with his settings given a valid user_token
let createUser = (user_tkoen, req, cb) => {
	req.models.users.create({
		user_token: req.body.user_token
	}, (err, user) => {
		createSettings(user, req, cb)
	})
}

// Create settings in the database for the user user
let createSettings = (user, req, cb) => {
	req.models.settings.create({ user_id: user.id }, () => {
		cb(null, user)
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

// Ask for a new access_token
router.post('/', function (req, res) {
	if (!req.body.user_token) {
		return res.sendStatus(401).end()
	}

	req.models.users.find({ user_token: req.body.user_token }).first((err, user) => {
		// No users exists with that user_token => create it
		if (!user) {
			// Check if it's a valid UUID
			if (!validate(req.body.user_token, 4)) {
				return res.sendStatus(403).end()
			}
			// Create the user and the device
			createUser(req.body.user_tkoen, req, (err, user) => {
				createDevice(user, req, (err, device) => {
					res.json(device).end()
				})
			})
		} else {
			// The user already exists, just create the device
			createDevice(user, req, (err, device) => {
				res.json(device).end()
			})
		}
	})

})

module.exports = router