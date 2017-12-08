const app = require('../index')
const crypto = require('crypto')
const uuidv4 = require('uuid/v4')
const request = require('supertest')

let user = {}
let db = null
let device = null
let access_token = crypto.randomBytes(48).toString('base64')

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
			user.id = device.user_id
		})
		.end(done)
}

describe('Settings API', () => {
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
		// Delete the test user, device and settings created during the test
		db.models.users.find({ id: user.id }).remove(() => {
			db.models.devices.find({ id: device.id }).remove(() => {
				db.models.settings.find({ user_id: user.id }).remove(() => {
					done()
				})
			})
		})
	})

	describe('GET /settings', () => {
		it('should return the user\'s settings', (done) => {
			request(app)
				.get('/api/v1/settings/')
				.set('X-Access-Token', device.access_token)
				.expect(200)
				.expect(res => {
					if (!res.body.max_walking_distance) {
						throw new Error('No settings returned')
					}
				})
				.end(done)
		})
	})

	describe('PATCH /settings', () => {
		it('should edit the user\'s settings', (done) => {
			request(app)
				.patch('/api/v1/settings/')
				.set('X-Access-Token', device.access_token)
				.send({'max_walking_distance': '4200'})
				.type('form')
				.expect(200)
				.expect(res => {
					if (res.body.max_walking_distance != 4200) {
						throw new Error('No settings returned')
					}
				})
				.end(done)
		})
	})
})