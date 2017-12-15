const app = require('../index')
const request = require('supertest')

const eventTitle = 'valid event name'
const startTime = new Date(new Date().getTime() + 1000 * 60 * 30)
const endTime = new Date(startTime.getTime() + 1000 * 60 * 60)

let db, device, calendar, event

describe('Events API', () => {
	before((done) => {
		db = app.get('db')
		device = app.get('testData').device
		db.models.calendars.create({
			user_id: device.user_id,
			name: "valid calendar name",
			color: "#FF0000"
		}, (err, _calendar) => {
			if (err) throw err
			calendar = _calendar
			done()
		})
	})

	after((done) => {
		// Delete the test calendar and event created during the test
		db.models.calendars.find({ id: calendar.id }).first((err, calendar) => {
			calendar.getEvents().remove(() => {
				calendar.remove(done)
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
					'lat': 45.464211,
					'lng': 9.191383,
					// Optional:
					'address': 'main street',
					'duration': 10,
					'repetitions': 'B0000001',
					'transports': 'B11111'
				})
				.expect(201)
				.expect(res => {
					if (!res.body.id) {
						throw new Error('No event returned')
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
					'end_time': endTime,
					'lat': 45.464211,
					'lng': 9.191383
				})
				.expect(201)
				.expect(res => {
					if (!res.body.id) {
						throw new Error('No event returned')
					}
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
								.expect(500)
				.end(done)
		})*/

		it('should throw a 400 error creating an event with an invalid name', (done) => {
			request(app)
				.put('/api/v1/calendars/' + calendar.id + '/events')
				.set('X-Access-Token', device.access_token)
				.send({
					'title': '',
					'start_time': startTime,
					'end_time': endTime,
					'lat': 45.464211,
					'lng': 9.191383
				})
				.expect(400)
				.end(done)
		})

		it('should throw a 400 error creating an event with an invalid lat/lng', (done) => {
			request(app)
				.put('/api/v1/calendars/' + calendar.id + '/events')
				.set('X-Access-Token', device.access_token)
				.send({
					'title': eventTitle,
					'start_time': startTime,
					'end_time': endTime
				})
				.expect(400)
				.end(done)
		})

		it('should throw a 400 error creating an event with duration > end - start', (done) => {
			request(app)
				.put('/api/v1/calendars/' + calendar.id + '/events')
				.set('X-Access-Token', device.access_token)
				.send({
					'title': eventTitle,
					'start_time': startTime,
					'end_time': endTime,
					'lat': 45.464211,
					'lng': 9.191383,
					'duration': endTime - startTime + 1
				})
				.expect(400)
				.end(done)
		})
	})

	describe('GET /events', () => {
		it('should return a list of events if a valid access token is provided with to and from parameters', (done) => {
			request(app)
				.get('/api/v1/calendars/' + calendar.id + '/events?from=' + new Date(startTime - 1000 * 60 * 60) + '&to=' + new Date(endTime + 1000 * 60 * 60))
				.set('X-Access-Token', device.access_token)
				.expect(200)
				.expect(res => {
					if (!res.body || res.body.length <= 0) {
						throw new Error('No event list received with to and from params')
					}
				})
				.end(done)
		})
	})
	describe('GET /events', () => {
		it('should return a list of events if a valid access token is provided without to and from parameters', (done) => {
			request(app)
				.get('/api/v1/calendars/' + calendar.id + '/events')
				.set('X-Access-Token', device.access_token)
				.expect(200)
				.expect(res => {
					if (!res.body || res.body.length <= 0) {
						throw new Error('No event list received without to and from params')
					}
				})
				.end(done)
		})
	})

	describe('PATCH /events/:id', () => {
		it('should modify the event if a valid access token is provided', (done) => {
			request(app)
				.patch('/api/v1/calendars/' + calendar.id + '/events/' + event.id)
				.set('X-Access-Token', device.access_token)
				.send({
					'title': 'Test',
					'start_time': startTime,
					'end_time': endTime,
					'lat': 45.464211,
					'lng': 9.191383
				})
				.expect(200)
				.expect(res => {
					if (res.body.title != 'Test') {
						throw new Error('Event has not been modified')
					}
				})
				.end(done)
		})

		it('should throw a 400 error updating an event with an invalid name', (done) => {
			request(app)
				.patch('/api/v1/calendars/' + calendar.id + '/events/' + event.id)
				.set('X-Access-Token', device.access_token)
				.send({
					'name': '',
					'start_time': startTime,
					'end_time': endTime,
					'lat': 45.464211,
					'lng': 9.191383
				})
				.expect(400)
				.end(done)
		})

		it('should throw a 400 error since the calendar does not exists', (done) => {
			request(app)
				.patch('/api/v1/calendars/-1/events/' + event.id)
				.set('X-Access-Token', device.access_token)
				.expect(400)
				.end(done)
		})
		it('should throw a 400 error since the event on the calendar does not exists', (done) => {
			request(app)
				.patch('/api/v1/calendars/' + calendar.id + '/events/-1')
				.set('X-Access-Token', device.access_token)
				.expect(400)
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

		it('should throw a 400 error trying to delete an event from a non-existing calendar', (done) => {
			request(app)
				.delete('/api/v1/calendars/987654321/events/' + event.id)
				.set('X-Access-Token', device.access_token)
				.expect(400)
				.end(done)
		})
	})
})