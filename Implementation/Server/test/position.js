const app = require('../index')
const request = require('supertest')



describe('Update user position', () => {
	let db
	before(() => {
		device = app.get('testData').device
	})

	describe('PATCH /position', () => {
		it('should return a 204', (done) => {
			request(app)
				.patch('/api/v1/position')
				.set('X-Access-Token', device.access_token)
				.send({
					'lat': 45.464257,
					'lng': 9.190209
				})
				.expect(204)
				.end(done)
		})

		it('should return a 400 if not token is set', (done) => {
			request(app)
				.patch('/api/v1/position')
				.set('X-Access-Token', device.access_token)
				.expect(400)
				.end(done)
		})
	})
})