const express = require('express')
const router = express.Router({ mergeParams: true })
const basicChecks = require('./schedule').basicChecks

const token = process.env.GOOGLE_MAPS_TOKEN
const googleMapsClient = require('@google/maps').createClient({ key: token });

// Return a list of User's Events
// Returns: a list of events
router.get('/', (req, res) => {
	req.user.getCalendars((err, calendars) => {
		let calendar_ids = []
		for (calendar of calendars) {
			calendar_ids.push(calendar.id)
		}
		req.models.events.find({ calendar_id: calendar_ids }, async (err, events) => {
			for (let event of events) {
				// Get the travels with await, so we can cycle through all with an async function
				let travels = await new Promise((resolve, reject) => {
					event.getTravels((err, travels) => {
						if (err) { return reject(err) }
						else { return resolve(travels) }
					})
				})

				let routes = {}
				for (t of travels) {
					let travel = {
						id: t.id,
						route: t.route,
						time: t.time,
						transport_mean: t.transport_mean,
						waypoints: t.waypoints
					}

					let route_id = travel.route
					delete travel.route
					if (!routes[route_id]) {
						routes[route_id] = { time: 0, travels: [] }
					}
					routes[route_id].travels.push(travel)
					routes[route_id].time += travel.time
				}

				let routes_ar = []
				for (let k in routes) {
					routes[k].id = k
					routes_ar.push(routes[k])
				}
				event.routes = routes_ar
			}
			return res.json(events).end()
		})
	})
})

// EVENT Factory: Restituisce un evento se tutto va bene, altrimenti null
let eventFactory = (req, cb) => {
	// Validate inputs:
	// These three fields are mandatory, meaning that if them are null or invalid,
	// then a 400 error is thrown.
	// All the other fields are optionals, meaning that if them are null or invalid,
	// they are just ignored and the default value (defined in models.js) is used
	let title = req.body.title || ''
	let start_time = new Date(req.body.start_time || undefined)
	let end_time = new Date(req.body.end_time || undefined)
	let address = req.body.address || ''
	if (!title || !start_time || !end_time || start_time >= end_time || !address) {
		return cb(null)
	}

	// Creating initial object
	let event = {
		calendar_id: req.params.calendar_id,
		title: title.trim(),
		start_time: new Date(new Date(start_time.setMilliseconds(0)).setSeconds(0)),
		end_time: new Date(new Date(end_time.setMilliseconds(0)).setSeconds(0)),
		address: address.trim()
	}

	googleMapsClient.geocode({
		address: event.address
	}, function (err, response) {
		if (!err && response.json.results.length > 0) {
			let res = response.json.results[0]
			event.address = res.formatted_address
			event.lat = res.geometry.location.lat
			event.lng = res.geometry.location.lng

			// Adding all the optional fields
			let duration = parseInt(req.body.duration)
			if (duration) event.duration = duration
			if (duration > (event.end_time - event.start_time)) {
				return cb(null)
			}

			let repetitions = (req.body.repetitions || '').trim()
			if (repetitions.match("[01]{7}")) {
				event.repetitions = repetitions
			}

			let transports = (req.body.transports || '').trim()
			if (transports.match("[01]{5}")) {
				event.transports = transports
			}
			return cb(event)
		} else {
			return cb(null)
		}
	});
}

// Create a new Event with the parameters specified
router.put('/', (req, res) => {
	eventFactory(req, event => {
		if (event == null) return res.sendStatus(400).end('invalid parameters')
		if (event.start_time < new Date()) {
			// Create the event
			req.models.events.create(event, (err, result) => {
				if (err) {
					return res.status(500).end()
				}
				return res.status(201).json(result).end()
			})
		} else {
			// Basic checks
			basicChecks(req.user, event, (err, reachable) => {
				if (reachable) {
					// Create the event
					req.models.events.create(event, (err, result) => {
						if (err) {
							return res.status(500).end()
						}
						return res.status(201).json(result).end()
					})
				} else {
					return res.status(412).end('not reachable')
				}
			})
		}
	})
})

router.delete('/:event_id', (req, res) => {
	// Delete the event
	req.models.calendars.find({ user_id: req.user.id, id: req.params.calendar_id }).first((err, calendar) => {
		// Calendar does not exists
		if (err || !calendar) return res.sendStatus(400).end()

		// Find the corresponding event and remove it
		req.models.events.find({
			calendar_id: req.params.calendar_id,
			id: req.params.event_id
		}).remove(err => {
			return res.status(204).end()
		})
	})
})

// Edit event
router.patch('/:event_id', (req, res) => {
	req.models.calendars.find({ user_id: req.user.id, id: req.params.calendar_id }).first((err, calendar) => {
		// Calendar not found
		if (err || !calendar) return res.sendStatus(400).end()
		req.models.events.find({
			calendar_id: req.params.calendar_id,
			id: req.params.event_id
		}).first((err, eventTarget) => {
			// Event not found
			if (err || !eventTarget) return res.sendStatus(400).end()
			// Try to generate an event
			eventFactory(req, eventUpdated => {
				if (eventUpdated == null) return res.sendStatus(400).end()
				// Copy attribute in eventUpdated to eventTarget
				delete eventUpdated.calendar_id

				if (eventUpdated.start_time < new Date()) {
					// Patch the event
					Object.assign(eventTarget, eventUpdated)
					eventTarget.save((err, result) => {
						return res.json(result).end()
					})
				} else {
					basicChecks(req.user, eventUpdated, (err, reachable) => {
						if (reachable) {
							// Patch the event
							Object.assign(eventTarget, eventUpdated)
							eventTarget.save((err, result) => {
								return res.json(result).end()
							})
						} else {
							return res.status(412).end('not reachable')
						}
					})
				}
			})
		})
	})
})

module.exports = {
	router: router
}