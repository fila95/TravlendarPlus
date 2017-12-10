const express = require('express')
const router = express.Router()

/*
for (var i = 0, len = calendars.length; i < len; i++) {
	id = calendars[i]['id']
	console.log("ID: " + id)
	req.models.events.find({ calendar_id: id }, (err2, events) => {
		console.log("ID: " + id)
		if (!events) {
			calendars[i]['calendar_events'] = null
		} else {
			calendars[i]['calendar_events'] = null
		}
	})
}
*/

// Sort the event looking at start_time in ascendent order
let sort = eventList => {
	return eventList.sort((a, b) => {
		// FIXME: mettere a posto in modo che funzioni con le date
		return a.start_time - b.start_time
	})
}

// Return true if there are at least two events that are overlapping, otherwise false
// Computational time: O(nlogn)
let overlap = eventList => {
	eventList = sort(eventList)
	for (let i = 0; i < eventList.length - 1; i++) {
		if (eventList[i].end_time > eventList[i + 1].start_time) {
			return true
		}
	}
	return false
}

// Return a list of timeSlots = [{start_time, end_time}, ...] where the flexibleEvent could fit
let timeSlots = (fixedEventList, flexibleEvent) => {
	let timeSlots = []

	// Remove all the events OUT of the flexible event window, and sort the remaining events
	let fixedEventListInWhichSearch = sort(
		fixedEventList.filter(v => {
			v.end_time > flexibleEvent.start_time && v.start_time < flexibleEvent.end_time
		})
	)

	// If there isn't any event, the time slot is the entire flexible event
	if (fixedEventListInWhichSearch.length == 0) {
		return [{ start_time: flexibleEvent.start_time, end_time: flexibleEvent.end_time }]
	}

	// Otherwise, search all the time slots
	for (let i = 0; i < fixedEventListInWhichSearch.length - 1; i++) {
		let possibleTimeSlot = {
			start_time: fixedEventListInWhichSearch[i].end_time,
			end_time: fixedEventListInWhichSearch[i + 1].start_time
		}

		let timeSlotDuration = possibleTimeSlot.end_time - possibleTimeSlot.start_time
		if (timeSlotDuration >= flexibleEvent.duration) {
			timeSlots.push(possibleTimeSlot)
		}
	}

	return timeSlots
}

// Return a list of User's Calenars
router.get('/', (req, res) => {
	req.user.getCalendars().each((err, calendar) => {
		calendar.getEvents((err, events) => {
			// TODO
			if (overlap(events)) return res.status(400).end('overlapping')


		})
	})
})

module.exports = router