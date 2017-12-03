const app = require('../index')
const request = require('supertest')
const crypto = require('crypto')
const uuidv4 = require('uuid/v4')
const orm = require('orm')

const calendarName = 'valid name'
let db = null
let device = null

let createData = (done) => {
	const user_token = uuidv4()
	db.models.users.create({
		user_token: user_token
	}, (err, user) => {
		if (err) throw err
		db.models.devices.create({
			user_id: user.id,
			access_token: crypto.randomBytes(48).toString('base64')
		}, (err, _device) => {
			if (err) throw err
			device = _device
			done()
		})
	})
}

describe('Calendars API', () => {
	before((done) => {
		// Connect to database
		// Create a test user and device
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
		// Delete the test user, device and calendar created during the test
		db.models.users.find({ id: device.user_id }).remove(() => {
			db.models.devices.find({ id: device.id }).remove(() => {
				db.models.calendars.find({ name: calendarName }).remove((index) => {
					done()
				})
			})
		})
	})

	describe('PUT /calendar', () => {
		it('should create a calendar if a valid access token is provided', (done) => {
			request(app)
				.put('/api/v1/calendar')
				.set('X-Access-Token', device.access_token)
				.send({
					'name': calendarName,
					'color': '#1278EF'
				})
				.type('form')
				.expect(200)
				.expect(res => {
					if (!res.body.id) {
						throw new Error('No calendar returned')
					}
				})
				.end(done)
		})

		it('should throw a 500 error creating a calendar with the same name of the previous', (done) => {
			request(app)
				.put('/api/v1/calendar')
				.set('X-Access-Token', device.access_token)
				.send({
					'name': calendarName,
					'color': '#1278EF'
				})
				.type('form')
				.expect(500)
				.end(done)
		})

		it('should throw a 400 error creating a calendar with an invalid name', (done) => {
			request(app)
				.put('/api/v1/calendar')
				.set('X-Access-Token', device.access_token)
				.send({
					'name': '',
					'color': '#1278EF'
				})
				.type('form')
				.expect(400)
				.end(done)
		})

		it('should throw a 400 error creating a calendar with an invalid color', (done) => {
			request(app)
				.put('/api/v1/calendar')
				.set('X-Access-Token', device.access_token)
				.send({
					'name': 'valid name',
					'color': 'invalid color'
				})
				.type('form')
				.expect(400)
				.end(done)
		})
	})

	describe('GET /calendars', () => {
		it('should return a list of calendars if a valid access token is provided', (done) => {
			request(app)
				.get('/api/v1/calendars')
				.set('X-Access-Token', device.access_token)
				.expect(200)
				.expect(res => {
					if (!res.body || res.body.length != 1) {
						throw new Error('No empty list')
					}
				})
				.end(done)
		})
	})

})