const app = require("../index")
const request = require('supertest')
const assert = require('assert')
const uuidv4 = require('uuid/v4')

const user_token = uuidv4()
let access_token = null

describe('POST /login', (t) => {
	it('should create a user and return a new access_token', (done) => {
		request(app)
			.post("/api/v1/login")
			.send({ 'user_token': user_token })
			.type('form')
			.expect(200)
			.expect(res => {
				if (res.body.access_token == undefined) {
					throw new Error(JSON.stringify(res.body))
				}
			})
			.end(done)
	})

	it('should return a new access_token if a valid user_token is provided', (done) => {
		request(app)
			.post("/api/v1/login")
			.send({ 'user_token': user_token })
			.type('form')
			.expect(200)
			.expect(res => {
				access_token = res.body.access_token
				if (res.body.access_token == undefined) {
					throw new Error("No access_token in response")
				}
			})
			.end(done)
	})
})


describe('GET /calendars', (t) => {
	it('should return an empty list of calendars if a valid access token is provided', (done) => {
		request(app)
			.get("/api/v1/calendars")
			.set('X-Access-Token', access_token)
			.expect(200)
			.expect(res => {
				if (res.body === {}) {
					throw new Error("No empty list")
				}
			})
			.end(done)
	})

	it('should return an error 401 if no access token is provided', (done) => {
		request(app)
			.get("/api/v1/calendars")
			.expect(401)
			.end(done)
	})

	it('should return an error 403 if invalid access token is provided', (done) => {
		request(app)
			.get("/api/v1/calendars")
			.set('X-Access-Token', "fail")
			.expect(403)
			.end(done)
	})
})

