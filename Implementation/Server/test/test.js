const app = require("../index")
const request = require('supertest')
const assert = require('assert')

describe('GET /hello', function (t) {
	it('should return hello', function () {
		request(app)
			.get("/hello")
			.then(response => {
				assert(response, 'hello')
			})
	})
})

describe('Authorization', function () {
	it('should expect a 401 if not authorization is provided', function (done) {
		request(app)
			.get("/helloWithAuth")
			.expect(401)
			.end((err, res) => {
				if (err) done(err)
				else done()
			})
	})

	it('should expect a 403 if invalid authorization is provided', function (done) {
		request(app)
			.get("/helloWithAuth")
			.set("X-Access-Token", "fail")
			.expect(403)
			.end((err, res) => {
				if (err) done(err)
				else done()
			})
	})
})

