const app = require('../index')
const crypto = require('crypto')
const uuidv4 = require('uuid/v4')

let user, device, calendar, customEvent

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
			user.settings = _settings
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

let createCalendar = (cb) => {
	db.models.calendars.create({
		user_id: user.id,
		'name': 'Test Calendar',
		'color': '#1278EF'
	}, (err, _calendar) => {
		if (err) throw err
		calendar = _calendar
		cb()
	})
}

let createEvent = (c_id, cb) => {
	db.models.events.create({
		title: "Test Event",
		address: "Test Address",
		lat: 45.464257,
		lng: 9.190209,
		start_time: new Date(2017, 11, 12, 12, 0),
		end_time: new Date(2017, 11, 12, 13, 20),
		duration: 1000 * 60 * 60,
		transports: "B1100",
		calendar_id: c_id
	}, (err, _event) => {
		if (err) throw err
		customEvent = _event
		cb()
	})
}

// Create a test user and device
let createData = (cb) => {
	createUser(() => {
		createDevice(() => {
			createCalendar(() => {
				createEvent(calendar.id, () => {
					// Adding user, device and calendars to the variable testData
					app.set('testData', { user: user, device: device, calendar: calendar, event: customEvent })
					cb()
				})
			})
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
	customEvent.remove(() => {
		calendar.remove(() => {
			device.remove(() => {
				user.getSettings().remove(() => {
					user.remove(done)
				})
			})
		})
	})
})