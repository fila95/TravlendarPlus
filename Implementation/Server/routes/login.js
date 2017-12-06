var validate = require('uuid-validate');
const express = require('express')
const crypto = require('crypto')
const router = express.Router()

let generateToken = () => {
	return crypto.randomBytes(48).toString('base64')
}

// Create a device in the database for the user user and
// return an object containing the access token
let createDevice = (user, req, res) => {
	let access_token = generateToken()
	req.models.devices.create({
		user_id: user.id,
		access_token: access_token,
		device_type: req.body.device_type || null
	}, err => {
		//if (err) throw err
		res.json({ access_token: access_token }).end()
	})
}

router.post('/login', function (req, res) {
	if (!req.body.user_token) {
		return res.sendStatus(401).end()
	}

	req.models.users.find({ user_token: req.body.user_token }, (err, users) => {
		if (users.length == 0) {
			// Check if it's a valid UUID
			if (!validate(req.body.user_token, 4)) {
				return res.sendStatus(403).end()
			}
			// Create the user and the device
			req.models.users.create({
				user_token: req.body.user_token
			}, (err, result) => {
				//if (err) throw err
				createDevice(result, req, res)
			})
		} else {
			// Create only the device
			createDevice(users[0], req, res)
		}
	})

})

module.exports = router