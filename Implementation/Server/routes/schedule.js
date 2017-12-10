const express = require('express')
const router = express.Router()

// Suppose that timeSlots are sorted and not overlapping
// Return the time in milliseconds for the given timeSlots
let freeTimeForTimeSlots = timeSlots => {
	let freeTime = 0
	for (timeSlot of timeSlots) {
		freeTime += (timeSlots.end_time - timeSlots.start_time)
	}
	return freeTime
}

// Suppose that timeSlots are sorted and not overlapping
// Return the total time in milliseconds in which the flexibleEvent cannot be scheduled
let occupiedTimeForTimeSlots = (flexibleEvent, timeSlots) => {
	let free = freeTimeForTimeSlots(timeSlots)
	let window = flexibleEvent.end_time - flexibleEvent.start_time
	return window - free
}

// Return a number from 0 to 1 where:
//   numbers near to 0 means 'quite fixed event'
//   numbers near to 1 means 'very flexible event'
let fitness = (event, timeSlots) => {
	return 1 - (event.duration / (event.end_time - event.start_time - occupiedTimeForTimeSlots(event, timeSlots)))
}

// Sort the flexible events looking at the fitness function:
// The events that are less flexible are the first, and the events that are the most flexible are the last
let sortWithFitness = (eventList, timeSlots) => {
	return eventList.sort((a, b) => {
		return fitness(a, timeSlots) - fitness(b, timeSlots)
	})
}

// Sort the event looking at start_time in ascendent order
let sort = eventList => {
	return eventList.sort((a, b) => {
		return a.start_time - b.start_time
	})
}

// Return two event that are overlapping, if there are, otherwise false
// Computational time: O(nlogn)
let overlap = eventList => {
	eventList = sort(eventList)
	for (let i = 0; i < eventList.length - 1; i++) {
		if (eventList[i].end_time > eventList[i + 1].start_time) {
			return [eventList[i].id, eventList[i + 1].id]
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

router.get('/', (req, res) => {
	req.user.getCalendars().each((err, calendar) => {
		// TODO prendere tutti gli eventi di OGGI
		calendar.getEvents((err, events) => {
			let overlapping = overlap(events)
			if (overlapping) return res.status(400).end('overlapping: ' + overlapping)
			// TODO
		})
	})
})

module.exports = router

if(process.env.ENV=='testing') {
	router.testFunctions = {
		timeSlots: timeSlots,
		overlap: overlap,
		sort: sort,
		sortWithFitness: sortWithFitness,
		fitness: fitness,
		occupiedTimeForTimeSlots: occupiedTimeForTimeSlots,
		freeTimeForTimeSlots: freeTimeForTimeSlots
	}
}