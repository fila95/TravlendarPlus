const express = require('express')
const orm = require('orm')
const app = express()

const port = process.env.PORT || 8080
const DB_URL = process.env.DATABASE_URL || "postgresql://postgres:postgres@localhost/travlendarplus"

// Middleware that will log all the requests on the stdout.
// ONLY FOR DEBUG PURPOSE
let logger = (req, res, next) => {
	console.log(new Date().toISOString() + " " + req.statusCode + " " + req.method + " " + req.url)
	next()
}

// Middleware that will populate the req.user only if access_token is valid
let auth = (req, res, next) => {
	let access_token = req.get('X-Access-Token')
	if (access_token != undefined) {
		req.models.devices.find({ access_token: access_token }, (err, devices) => {
			if (devices.length == 1) {
				let device = devices[0]
				device.getUser((user) => {
					req.user = user
					return next()
				})
			} else {
				res.sendStatus(403).end()
			}	
		})
	} else {
		res.sendStatus(401).end()
	}
}

let defineDatabase = (db, models, next) => {
	db.load("./models", (err) => {
		if (err) { throw err; }
		db.sync((err) => {
			if (err) { throw err }
			// copy db.models properties in models
			Object.assign(models, db.models)
			next();
		})
	})
}

// Set the middlewares
app.use(orm.express(DB_URL, { define: defineDatabase, debug: true }))
app.use(auth)
app.use(logger)

// Disable express header
app.disable('x-powered-by');

// Routes
app.get("/hello", (req, res) => {
	res.end("hello")
});

app.get("/helloWithAuth", (req, res) => {
	res.json(req.user)
	res.end()
});

// Events endpoints:
app.get('/api/v1/events', (req, res) => {
	req.models.events.find({})
})

if (require.main === module) {
	// Start listening
	let server = app.listen(port, () => {
		console.log("Listening on :" + port)
	});

	setTimeout(function(){server.close(function(){})}, 2000)
} else {
	module.exports = app
}