const app = require('../index')
const request = require('supertest')
const uuidv4 = require('uuid/v4')

const user_token = uuidv4()
let access_token = null

describe('POST /login', () => {
	it('should return a new access_token if a valid user_token is provided', (done) => {
		request(app)
			.post('/api/v1/login')
			.send({ 'user_token': user_token })
			.type('form')
			.expect(200)
			.expect(res => {
				if (res.body.access_token == undefined) {
					throw new Error('No access_token in response')
				}
				access_token = res.body.access_token
			})
			.end(done)
	})

	it('should return an error 401 if no user token is provided', (done) => {
		request(app)
			.post('/api/v1/login')
			.expect(401)
			.end(done)
	})

	it('should return an error 403 if invalid user token is provided', (done) => {
		request(app)
			.post('/api/v1/login')
			.send({ 'user_token': 'fail' })
			.type('form')
			.expect(403)
			.end(done)
	})
})