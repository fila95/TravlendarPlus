const app = require("../index")
const request = require('supertest')
const assert = require('assert')
const uuidv4 = require('uuid/v4')

describe('POST /login', (t) => {
	let user_token = uuidv4();

	it('should create a user and return a new access_token', (done) => {
		request(app)
			.post("/api/v1/login")
			.send({ 'user_token': user_token })
			.type('form')
			.expect(res => {
				if(res.body.access_token==undefined) {
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
			.expect(res => {
				if(res.body.access_token==undefined) {
					throw new Error("No access_token in response")
				}
			})
			.end(done)
	})
})