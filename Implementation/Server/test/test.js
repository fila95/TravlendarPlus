const app = require("../index")
const request = require('supertest');
const assert = require('assert');

describe('GET /hello', function () {
	it('should return hello', function () {
		request(app)
			.get("/hello")
			.then(response => {
				assert(response, 'hello')
			})
	});
});