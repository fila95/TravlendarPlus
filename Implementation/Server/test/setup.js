const app = require('../index')
const crypto = require('crypto')
const uuidv4 = require('uuid/v4')

let user, device

let createUser = (cb) => {
	db.models.users.create({
		user_token: uuidv4()
	}, (err, _user) => {
		if (err) throw err
		user = _user
		db.models.settings.create({
			user_id: user.id
		}, (err, _settings) => {
			if (err) throw err
			cb()
		})
	})
}

let createDevice = (cb) => {
	db.models.devices.create({
		user_id: user.id,
		access_token: crypto.randomBytes(48).toString('base64')
	}, (err, _device) => {
		if (err) throw err
		device = _device
		cb()
	})
}

// Create a test user and device
let createData = (cb) => {
	createUser(() => {
		createDevice(() => {
			// Adding user and device to the variable testData
			app.set('testData', { user: user, device: device })
			cb()
		})
	})

}

before((done) => {
	// Starting up, the app will set the variable db
	// If it's not already set, wait for the event db_connected
	if (!app.get('db')) {
		app.on('db_connected', (_db) => {
			db = _db
			createData(done)
		})
	} else {
		db = app.get('db')
		createData(done)
	}
})

after((done) => {
	device.remove(() => {
		user.getSettings().remove(() => {
			user.remove(done)
		})
	})
})