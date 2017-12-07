const express = require('express')
const router = express.Router({ mergeParams: true })

// Return a list of User's Events
router.get('/', (req, res) => {
	req.models.users.find({ id: req.user.id }, (err, users) => {
		//if (err) throw err
		let calendars = {}
		/*users[0].getCalendars().each(calendar => {
			calendar.getEvents((events) => {
				calendars[calendar.id] = events
			})
		}).get(() => {
			console.log(calendars)
			return res.json(calendars).end()
		})*/

		users[0].getCalendars((err, calendars) =>  {
			calendar_ids = []
			for (calendar of calendars) {
				calendar_ids.push(calendar.id)
			}
			req.models.events.find({ calendar_id: calendar_ids }, (err, events) => {
				return res.json(events).end()
			})
		})
	})
})

// Create a new Event with the parameters specified
router.put('/', (req, res) => {
	// Validate inputs:
	// These three fields are mandatory, meaning that if them are null or invalid,
	// then a 400 error is thrown.
	// All the other fields are optionals, meaning that if them are null or invalid,
	// they are just ignored and the default value (defined in models.js) is used
	let title = req.body.title
	let start_time = new Date(req.body.start_time || undefined)
	let end_time = new Date(req.body.end_time || undefined)
	if (!title || !start_time || !end_time) {
		return res.sendStatus(400).end()
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
	}

	let duration = parseInt(req.body.duration)
	if (duration) event.duration = duration

	let repetitions = (req.body.repetitions || '').trim()
	if (repetitions.match("B[01]{7}")) {
		event.repetitions = repetitions
	}

	let transports = (req.body.transports || '').trim()
	if (transports.match("B[01]{5}")) {
		event.transports = transports
	}

	// Create the event
	req.models.events.create(event, (err, result) => {
		if (err) return res.sendStatus(500).end()

		return res.status(201).json(result).end()
	})

})

router.delete('/:event_id', (req, res) => {
	// Delete the event
	req.models.events.find({
		id: req.params.event_id
	}).remove(err => {
		return res.status(204).end()
	})
})

module.exports = router