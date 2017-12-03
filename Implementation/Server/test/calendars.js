const app = require('../index')
const request = require('supertest')
const uuidv4 = require('uuid/v4')

const db = app.get('db')
const user_token = uuidv4()
let access_token = null

describe('GET /calendars', () => {
	it('should return an empty list of calendars if a valid access token is provided', (done) => {
		db.models.users.create({
			user_token: user_token
		}, (err, user) => {
			if (err) throw err
			db.models.devices.create({
				user_id: user.id,
				access_token: crypto.randomBytes(48).toString('base64')
			}, (err, device) => {
				request(app)
					.get('/api/v1/calendars')
					.set('X-Access-Token', device.access_token)
					.expect(200)
					.expect(res => {
						if (res.body === {}) {
							throw new Error('No empty list')
						}
					})
					.end(done)
			})
		})
	})
})

describe('POST /calendars', () => {
	it('should create a calendar if a valid access token is provided', (done) => {
		request(app)
			.post('/api/v1/calendars')
			.set('X-Access-Token', access_token)
			.send({
				'name': 'name test',
				'color': '#1278EF'
			})
			.type('form')
			.expect(200)
			.expect(res => {
				if (!res.body.id) {
					throw new Error('No calendar returned')
				}
			})
			.end(done)
	})
})
