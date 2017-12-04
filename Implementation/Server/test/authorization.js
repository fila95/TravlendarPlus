const app = require('../index')
const request = require('supertest')

const baseURL = "/api/v1"
const endpoints = [
	{
		"endpoint": "/calendars",
		"verbs": ["GET", "PUT"]
	}
]

describe('Authorization', () => {
	endpoints.forEach((obj) => {
		let endpoint = obj.endpoint
		obj.verbs.forEach((verb) => {
			describe(verb + ' ' + baseURL + endpoint, () => {
				it('should return an error 401 if no access token is provided', (done) => {
					request(app)
					[verb.toLowerCase()](baseURL + endpoint)
						.expect(401)
						.end(done)
				})

				it('should return an error 403 if invalid access token is provided', (done) => {
					request(app)
					[verb.toLowerCase()](baseURL + endpoint)
						.set('X-Access-Token', 'invalid access_token')
						.expect(403)
						.end(done)
				})
			})
		})
	})
})
