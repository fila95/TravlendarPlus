const app = require('../index')
const request = require('supertest')

let db

describe('Push Notification Token', () => {
	before(() => {
		device = app.get('testData').device
	})

	describe('PUT /pushNotificationToken', () => {
		it('should return a 204', (done) => {
			request(app)
				.put('/api/v1/pushNotificationToken')
				.set('X-Access-Token', device.access_token)
				.send({
					'token': 'this is a test of a valid token'
				})
				.expect(204)
				.end(done)
		})

		it('should return a 400 if not token is set', (done) => {
			request(app)
				.put('/api/v1/pushNotificationToken')
				.set('X-Access-Token', device.access_token)
				.expect(400)
				.end(done)
		})
	})
})