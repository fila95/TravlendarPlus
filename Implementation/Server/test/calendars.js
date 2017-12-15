const app = require('../index')
const request = require('supertest')

const calendarName = 'valid name'
let db, device, calendar

describe('Calendars API', () => {
	before(() => {
		db = app.get('db')
		device = app.get('testData').device
	})

	after((done) => {
		// Delete all the test calendars created during the test
		db.models.calendars.find({ user_id: device.user_id }).remove(() => {
			done()
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
				.expect(201)
				.expect(res => {
					if (!res.body.id) {
						throw new Error('No calendar returned')
					}
					calendar = res.body
				})
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
				.expect(400)
				.end(done)
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