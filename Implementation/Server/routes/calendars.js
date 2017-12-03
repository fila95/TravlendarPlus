const express = require('express')
const router = express.Router()

// Return a list of User's Calendars
router.get('/calendars', (req, res) => {
	req.models.calendars.find({ user_id: req.user.id }, (err, results) => {
		res.json(results).end()
	})
})

// Function that returns true if the color is valid
// Example of valid color: #F203b1
let validColor = (color) => {
	return color.match("#[0-9a-fA-F]{6}")
}

// Create a new Calendar with the name and color specified
router.post('/calendars', (req, res) => {
	// Validate inputs
	if (!req.body.name || !req.body.color) {
		return res.sendStatus(400).end()
	}
	let name = req.body.name.trim()
	let color = req.body.color.trim()
	if(!validColor(color)) {
		return res.sendStatus(400).end()
	}

	// Create the calendar
	req.models.calendars.create({
		user_id: req.user.id,
		name: name,
		color: color
	}, (err, result) => {
		if (err) return res.sendStatus(500).end()
		
		return res.json(result).end()
	})
})

module.exports = router