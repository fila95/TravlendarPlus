const app = require('../index')
const request = require('supertest')
const crypto = require('crypto')
const uuidv4 = require('uuid/v4')
const orm = require('orm')

const calendarName = 'valid name'
let db = null
let device = null
let calendar = null

let createData = (done) => {
	const user_token = uuidv4()
	request(app)
		.post('/api/v1/login')
		.send({ 'user_token': user_token })
		.type('form')
		.expect(200)
		.expect(res => {
			if (res.body.access_token == undefined) {
				throw new Error('No access_token in response')
			}
			device = res.body
		})
		.end(done)
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
			db.models.settings.find({ user_id: device.user_id }).remove(() => {
				db.models.calendars.find({ user_id: device.user_id }).remove(() => {
					db.models.devices.find({ id: device.id }).remove(() => {
						done()
					})
				})
			})
		})
	})

	describe('PUT /calendars', () => {
		it('should create a calendar if a valid access token is provided', (done) => {
			request(app)
				.put('/api/v1/calendars')
				.set('X-Access-Token', device.access_token)
				.send({
					'name': calendarName,
					'color': '#1278EF'
				})
				.type('form')
				.expect(201)
				.expect(res => {
					if (!res.body.id) {
						throw new Error('No calendar returned')
					}
					calendar = res.body
				})
				.end(done)
		})

		it('should throw a 500 error creating a calendar with the same name of the previous', (done) => {
			request(app)
				.put('/api/v1/calendars')
				.set('X-Access-Token', device.access_token)
				.send({
					'name': calendarName,
					'color': '#4378EF'
				})
				.type('form')
				.expect(500)
				.end(done)
		})

		it('should throw a 400 error creating a calendar with an invalid name', (done) => {
			request(app)
				.put('/api/v1/calendars')
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
				.put('/api/v1/calendars')
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
						throw new Error('No calendar list received')
					}
				})
				.end(done)
		})
	})

	describe('PATCH /calendars/:id', () => {
		it('should update a calendar if a valid access token is provided', (done) => {
			request(app)
				.patch('/api/v1/calendars/' + calendar.id)
				.set('X-Access-Token', device.access_token)
				.send({
					'name': 'update',
					'color': '#1234AA'
				})
				.type('form')
				.expect(200)
				.expect(res => {
					if (res.body.name != 'update' || res.body.color != '#1234AA') {
						throw new Error('Calendar was not modified')
					}
				})
				.end(done)
		})

		it('should throw a 400 error edit a calendar with an invalid name', (done) => {
			request(app)
				.patch('/api/v1/calendars/' + calendar.id)
				.set('X-Access-Token', device.access_token)
				.send({
					'name': '',
					'color': '#1278EF'
				})
				.type('form')
				.expect(400)
				.end(done)
		})

		it('should throw a 400 error edit a calendar with an invalid color', (done) => {
			request(app)
				.patch('/api/v1/calendars/' + calendar.id)
				.set('X-Access-Token', device.access_token)
				.send({
					'name': 'valid name',
					'color': 'invalid color'
				})
				.type('form')
				.expect(400)
				.end(done)
		})

		it('should throw a 400 error trying to edit a non-existing calendar', (done) => {
			request(app)
				.patch('/api/v1/calendars/987654321')
				.set('X-Access-Token', device.access_token)
				.send({
					'name': 'valid name',
					'color': '#123456'
				})
				.type('form')
				.expect(400)
				.end(done)
		})

		it('should throw a 500 as there exists another calendar with the same name', (done) => {
			request(app)
				.put('/api/v1/calendars')
				.set('X-Access-Token', device.access_token)
				.send({
					'name': 'calendar 2',
					'color': '#1278EF'
				})
				.type('form')
				.expect(201)
				.expect(res => {
					if (!res.body.id) {
						throw new Error('No calendar returned')
					}
				}).end(() => {
					request(app)
						.patch('/api/v1/calendars/' + calendar.id)
						.set('X-Access-Token', device.access_token)
						.send({
							'name': 'calendar 2',
							'color': '#1278EF'
						})
						.type('form')
						.expect(500)
						.end(done)
				})
		})
	})

	describe('DELETE /calendars/:id', () => {
		it('should delete the calendar if a valid access token is provided', (done) => {
			request(app)
				.delete('/api/v1/calendars/' + calendar.id)
				.set('X-Access-Token', device.access_token)
				.expect(204)
				.end(done)
		})
	})


})