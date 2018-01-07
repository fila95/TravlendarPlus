const express = require('express')
const router = express.Router()

// Return a list of User's Calendars
router.get('/', (req, res) => {
	req.user.getCalendars((err, calendars) => {
		res.json(calendars).end()
	})
})

// Function that returns true if the color is valid
// Example of valid color: #F203b1
let validColor = (color) => {
	return color.match("#[0-9a-fA-F]{6}")
}

// Create a new Calendar with the name and color specified
router.put('/', (req, res) => {
	// Validate inputs
	if (!req.body.name || !req.body.color) {
		return res.sendStatus(400).end()
	}
	let name = req.body.name.trim()
	let color = req.body.color.trim()
	if (!validColor(color)) {
		return res.sendStatus(400).end()
	}

	// Create the calendar
	req.models.calendars.create({
		user_id: req.user.id,
		name: name,
		color: color
	}, (err, result) => {
		return res.status(201).json(result).end()
	})
})

// Delete the calendar
router.delete('/:calendar_id', (req, res) => {
	req.models.calendars.find({
		user_id: req.user.id,
		id: req.params.calendar_id
	}).first((err, calendar) => {
		calendar.setEvents([], (err) => {
			calendar.remove(() => {
				return res.status(204).end()
			})
		})
	})
})


// Edit calendar with the name and color specified
router.patch('/:calendar_id', (req, res) => {
	if (!req.body.name || !req.body.color) {
		return res.sendStatus(400).end()
	}
	let name = req.body.name.trim()
	let color = req.body.color.trim()
	if (!validColor(color)) {
		return res.sendStatus(400).end()
	}

	req.models.calendars.find({
		user_id: req.user.id,
		id: req.params.calendar_id
	}).first((err, calendar) => {
		if (err || !calendar) return res.sendStatus(400).end()
		calendar.name = name;
		calendar.color = color;
		calendar.save((err, result) => {
			return res.json(result).end()
		});

	})
})

module.exports = {
	router: router
}