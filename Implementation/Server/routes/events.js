const express = require('express')
const router = express.Router({ mergeParams: true })

// Return a list of User's Events
// Parameters: from and to are two Dates that allow a paging for this endpoint
// Returns: a list of events, from the Date from, to the Date to
router.get('/', (req, res) => {
	let from, to
	if (req.query.from) {
		from = new Date(req.query.from)
	} else {
		from = new Date()
	}
	if (req.query.to) {
		to = new Date(req.query.to)
	} else {
		to = new Date(from.getTime())
		to.setHours(to.getHours() + 24)
	}

	let calendars = {}

	req.user.getCalendars((err, calendars) => {
		let calendar_ids = []
		for (calendar of calendars) {
			calendar_ids.push(calendar.id)
		}
		req.models.events.findFromToInCalendar(from, to, calendar_ids, (err, events) => {
			return res.json(events).end()
		})
	})
})

// EVENT Factory: Restituisce un evento se tutto va bene, altrimenti null
let eventFactory = req => {
	// Validate inputs:
	// These three fields are mandatory, meaning that if them are null or invalid,
	// then a 400 error is thrown.
	// All the other fields are optionals, meaning that if them are null or invalid,
	// they are just ignored and the default value (defined in models.js) is used
	let title = req.body.title
	let start_time = new Date(req.body.start_time || undefined)
	let end_time = new Date(req.body.end_time || undefined)
	if (!title || !start_time || !end_time || start_time >= end_time) {
		return null
	}

	// Creating initial object
	let event = {
		calendar_id: req.params.calendar_id,
		title: req.body.title.trim(),
		start_time: start_time,
		end_time: end_time
	}

	// Adding all the optional fields
	let address = (req.body.address || '').trim()
	if (address) event.address = address

	let lat = parseFloat(req.body.lat)
	let lng = parseFloat(req.body.lng)
	if (lat && lng) {
		event.lat = lat
		event.lng = lng
	} else {
		return null
	}

	let duration = parseInt(req.body.duration)
	if (duration) event.duration = duration
	if (duration > (event.end_time - event.start_time)) return null

	let repetitions = (req.body.repetitions || '').trim()
	if (repetitions.match("B[01]{7}")) {
		event.repetitions = repetitions
	}

	let transports = (req.body.transports || '').trim()
	if (transports.match("B[01]{5}")) {
		event.transports = transports
	}
	return event
}

// Create a new Event with the parameters specified
router.put('/', (req, res) => {
	let event = eventFactory(req)
	// Error
	if (event == null) return res.sendStatus(400).end()

	// Create the event
	req.models.events.create(event, (err, result) => {
		return res.status(201).json(result).end()
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
			eventUpdated = eventFactory(req)
			if (eventUpdated == null) return res.sendStatus(400).end()
			// Copy attribute in eventUpdated to eventTarget
			for (var property in eventUpdated) {
				// But not its ID
				if (property != 'calendar_id') {
					eventTarget[property] = eventUpdated[property]
				}
			}
			eventTarget.save((err, result) => {
				//if (err) return res.sendStatus(500).end()
				return res.json(result).end()
			})

		})

	})
})

// Parsing the transports from binary encoding. Example: 1100 -> ["walking","bicycling"]
let parseTransports = (transports) => {
	let sTransports=["walking","bicycling", "transit", "driving"]
	mask=transports.split('').map(transport => transport == 1)
	return sTransports.filter((transport,index) => mask[index])
}

module.exports = router