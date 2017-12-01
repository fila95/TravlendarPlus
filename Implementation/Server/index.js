const express = require('express')
const bodyParser = require('body-parser')
const orm = require('orm')
const app = express()

const port = process.env.PORT || 8080
const DB_URL = process.env.DATABASE_URL || "postgresql://postgres:postgres@localhost/travlendarplus"

// Middleware that will log all the requests on the stdout.
// ONLY FOR DEBUG PURPOSE
let logger = (req, res, next) => {
	if (process.env.DEBUG) {
		console.log(new Date().toISOString() + " " + req.statusCode + " " + req.method + " " + req.url)
	}
	next()
}

// Load the database schema explained in models.js
let defineDatabase = (db, models, next) => {
	db.load("./models", err => {
		if (err) { throw err }
		db.sync(err => {
			if (err) { throw err }
			// copy db.models properties in models
			Object.assign(models, db.models)
			next()
		})
	})
}

// Set the middlewares
app.use(bodyParser.urlencoded({ extended: true }))
app.use(orm.express(DB_URL, { define: defineDatabase, debug: true }))
app.use(logger)
app.use(require('./routes'))

// Disable express header
app.disable('x-powered-by')

// If the app was not imported as a library, start the server
if (require.main === module) {
	let server = app.listen(port, () => {
		console.log("Listening on :" + port)
	})
} else {
	module.exports = app
}