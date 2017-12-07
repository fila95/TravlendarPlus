const app = require('../index')
const request = require('supertest')
const uuidv4 = require('uuid/v4')

const user_token = uuidv4()
let db = null

describe('Authentication', () => {
	before((done) => {
		// Connect to database
		if (!app.get('db')) {
			app.on('db_connected', (_db) => {
				db = _db
				done()
			})
		} else {
			db = app.get('db')
			done()
		}
	})

	after((done) => {
		// Delete the test user and devices created before
		db.models.users.find({ user_token: user_token }).first((err, user) => {
			user.getDevices().remove((err) => {
				user.getSettings().remove((err) => {
					user.remove((err) => {
						done()
					})
				})
			})
		})
	})

	it('should create a new user and a new access_token if a valid user_token is provided', (done) => {
		request(app)
			.post('/api/v1/login')
			.send({ 'user_token': user_token })
			.type('form')
			.expect(200)
			.expect(res => {
				if (res.body.access_token == undefined) {
					throw new Error('No access_token in response')
				}
			})
			.end(done)
	})

	it('should simply return a new access_token if a valid existing user_token is provided', (done) => {
		request(app)
			.post('/api/v1/login')
			.send({ 'user_token': user_token })
			.type('form')
			.expect(200)
			.expect(res => {
				if (res.body.access_token == undefined) {
					throw new Error('No access_token in response')
				}
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