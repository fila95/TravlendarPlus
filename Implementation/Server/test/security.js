const app = require('../index')
const itParam = require('mocha-param').itParam;
const request = require('supertest')

const baseURL = "/api/v1/"
const endpoints = [
	"/calendars"
]

endpoints.forEach((endpoint) => {
	describe('Security test on ' + endpoint, () => {
		it('should return an error 401 if no access token is provided', (done) => {
			request(app)
				.get('/api/v1/calendars')
				.expect(401)
				.end(done)
		})

		it('should return an error 403 if invalid access token is provided', (done) => {
			request(app)
				.get('/api/v1/calendars')
				.set('X-Access-Token', 'fail')
				.expect(403)
				.end(done)
		})
	})
})
