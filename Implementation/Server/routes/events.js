const express = require('express')
const router = express.Router({ mergeParams: true })
const basicChecks = require('./schedule').basicChecks

const token = process.env.GOOGLE_MAPS_TOKEN
const googleMapsClient = require('@google/maps').createClient({ key: token });

// Return a list of User's Events
// Parameters: from and to are two Dates that allow a paging for this endpoint
// Returns: a list of events, from the Date from, to the Date to
router.get('/', (req, res) => {
	let calendars = {}

	req.user.getCalendars((err, calendars) => {
		let calendar_ids = []
		for (calendar of calendars) {
			calendar_ids.push(calendar.id)
		}
		req.models.events.find({ calendar_id: calendar_ids }, (err, events) => {
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
		start_time: start_time,
		end_time: end_time,
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
			if (repetitions.match("B[01]{7}")) {
				event.repetitions = repetitions
			}

			let transports = (req.body.transports || '').trim()
			if (transports.match("B[01]{5}")) {
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
		if (event == null) return res.sendStatus(400).end()
		
		// Basic checks
		basicChecks(req.user, event, (reachable) => {
			if (reachable) {
				// Create the event
				req.models.events.create(event, (err, result) => {
					return res.status(201).json(result).end()
				})
			} else {
				return res.status(400).end('not reachable')
			}
		})
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
				Object.assign(eventTarget, eventUpdated)
				eventTarget.save((err, result) => {
					//if (err) return res.sendStatus(500).end()
					return res.json(result).end()
				})
			})
		})
	})
})

module.exports = {
	router: router
}