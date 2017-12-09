const app = require('../index')
const request = require('supertest')

let device = null

describe('Settings API', () => {
	before((done) => {
		device = app.get('testData').device
		done()
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
				.send({
					'max_walking_distance': '4200',
					'start_public_transportation': '10:00:00'
				})
				.type('form')
				.expect(200)
				.expect(res => {
					if (res.body.max_walking_distance != 4200 || res.body.start_public_transportation != "10:00:00") {
						throw new Error('No settings returned')
					}
				})
				.end(done)
		})

		it('should throw a 400 error trying to edit user\'s settings in invalid way', (done) => {
			request(app)
				.patch('/api/v1/settings/')
				.set('X-Access-Token', device.access_token)
				.send({
					'start_public_transportation': 'INVALID'
				})
				.type('form')
				.expect(400)
				.end(done)
		})
	})
})