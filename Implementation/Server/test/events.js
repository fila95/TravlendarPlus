const app = require('../index')
const request = require('supertest')
const crypto = require('crypto')
const uuidv4 = require('uuid/v4')
const orm = require('orm')

const eventTitle = 'valid event name'
const startTime = '2017-12-04T11:00:47.676Z'
const endTime = '2017-12-04T13:01:40.143Z'

let db = null
let user = null
let device = null
let calendar = null
let event = null
let access_token = crypto.randomBytes(48).toString('base64')

let createData = (done) => {
	const user_token = uuidv4()
	db.models.users.create({
		user_token: user_token
	}, (err, _user) => {
		if (err) throw err
		user = _user
		db.models.devices.create({
			user_id: user.id,
			access_token: access_token
		}, (err, _device) => {
			if (err) throw err
			device = _device
			db.models.calendars.create({
				user_id: user.id,
				name: "valid calendar name",
				color: "#FF0000"
			}, (err, _calendar) => {
				if (err) throw err
				calendar = _calendar
				done()
			})
		})
	})
}

describe('Events API', () => {
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
		// Delete the test user, device, calendar and event created during the test
		db.models.users.find({ id: user.id }).remove(() => {
			db.models.devices.find({ id: device.id }).remove(() => {
				db.models.calendars.find({ id: calendar.id }).remove(() => {
					db.models.events.find({ id: event.id }).remove(() => {
						done()
					})
				})
			})
		})
	})

	describe('PUT /events', () => {
		it('should create an event with all the details if a valid access token is provided', (done) => {
			request(app)
				.put('/api/v1/calendars/' + calendar.id + '/events')
				.set('X-Access-Token', device.access_token)
				.send({
					// Mandatory:
					'title': eventTitle,
					'start_time': startTime,
					'end_time': endTime,
					// Optional:
					'address': 'main street',
					'lat': 45.464211,
					'lng': 9.191383,
					'duration': 10,
					'repetitions': 'B0000001',
					'transports': 'B11111'
				})
				.type('form')
				.expect(201)
				.expect(res => {
					if (!res.body.id) {
						throw new Error('No calendar returned')
					}
					event = res.body
				})
				.end(done)
		})

		it('should create an event with only the mandatory fields if a valid access token is provided', (done) => {
			request(app)
				.put('/api/v1/calendars/' + calendar.id + '/events')
				.set('X-Access-Token', device.access_token)
				.send({
					// Mandatory:
					'title': eventTitle,
					'start_time': startTime,
					'end_time': endTime
				})
				.type('form')
				.expect(201)
				.expect(res => {
					if (!res.body.id) {
						throw new Error('No calendar returned')
					}
					event = res.body
				})
				.end(done)
		})

		/* TODO: fix routes/events.js in order to not allow overlapping events
		 * For now it returns a 201 Created
		it('should throw a 500 error creating an event overlapping', (done) => {
			request(app)
				.put('/api/v1/calendars/'+calendar.id+'/events')
				.set('X-Access-Token', device.access_token)
				.send(event)
				.type('form')
				.expect(500)
				.end(done)
		})*/

		it('should throw a 400 error creating an event with an invalid parameter', (done) => {
			request(app)
				.put('/api/v1/calendars/' + calendar.id + '/events')
				.set('X-Access-Token', device.access_token)
				.send({
					'name': ''
				})
				.type('form')
				.expect(400)
				.end(done)
		})
	})

	describe('GET /events', () => {
		it('should return a list of events if a valid access token is provided', (done) => {
			request(app)
				.get('/api/v1/calendars/' + calendar.id + '/events')
				.set('X-Access-Token', device.access_token)
				.expect(200)
				.expect(res => {
					if (!res.body || res.body.length<=0) {
						throw new Error('No event list received')
					}
				})
				.end(done)
		})
	})

	describe('DELETE /events/:id', () => {
		it('should delete the event if a valid access token is provided', (done) => {
			request(app)
				.delete('/api/v1/calendars/' + calendar.id + '/events/' + event.id)
				.set('X-Access-Token', device.access_token)
				.expect(204)
				.end(done)
		})
	})
})