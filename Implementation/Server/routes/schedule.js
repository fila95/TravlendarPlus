const express = require('express')
const router = express.Router()

// Suppose that timeSlots are sorted and not overlapping
// Return the time in milliseconds for the given timeSlots
let freeTimeForTimeSlots = (flexibleEvent, timeSlots) => {
	let freeTime = 0
	for (timeSlot of timeSlots) {
		let s, e
		s = (timeSlot.start_time > flexibleEvent.start_time) ? flexibleEvent.start_time : timeSlot.end_time
		e = (timeSlot.end_time < flexibleEvent.end_time) ? flexibleEvent.end_time : timeSlot.end_time
		freeTime += (e - s)
	}
	return freeTime
}

// Suppose that timeSlots are sorted and not overlapping
// Return the total time in milliseconds in which the flexibleEvent cannot be scheduled
let occupiedTimeForTimeSlots = (flexibleEvent, timeSlots) => {
	let free = freeTimeForTimeSlots(flexibleEvent, timeSlots)
	let window = flexibleEvent.end_time - flexibleEvent.start_time
	return window - free
}

// Return a number from 0 to 1 where:
//   numbers near to 0 means 'quite fixed event'
//   numbers near to 1 means 'very flexible event'
let fitness = (flexibleEvent, timeSlots) => {
	return 1 - (flexibleEvent.duration / (flexibleEvent.end_time - flexibleEvent.start_time - occupiedTimeForTimeSlots(flexibleEvent, timeSlots)))
}

// Sort the flexible events looking at the fitness function:
// The events that are less flexible are the first, and the events that are the most flexible are the last
let sortWithFitness = (eventList) => {
	return eventList.sort((a, b) => {
		return fitness(a, a.timeSlots) - fitness(b, b.timeSlots)
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
let timeSlots = (fixedEventList, _flexibleEvent) => {
	// Copy flexible event to not modify the original
	let flexibleEvent = {
		start_time: _flexibleEvent.start_time,
		end_time: _flexibleEvent.end_time,
		duration: _flexibleEvent.duration
	}
	let timeSlots = []

	// Remove all the events OUT of the flexible event window, and sort the remaining events
	let fixedEventListInWhichSearch = sort(
		fixedEventList.filter(v => {
			return v.end_time > flexibleEvent.start_time && v.start_time < flexibleEvent.end_time
		})
	)

	// If the start of the flexible event is inside an existing fixed event, shift the start to the end of that event
	let first_fixed_event = fixedEventListInWhichSearch[0]
	if (flexibleEvent.start_time > first_fixed_event.start_time) {
		flexibleEvent.start_time = first_fixed_event.end_time
		fixedEventListInWhichSearch.splice(0, 1)
	}

	// If the end of the flexible event is inside an existing fixed event, shift the end to the start of that event
	let last_fixed_event = fixedEventListInWhichSearch[fixedEventListInWhichSearch.length - 1]
	if (flexibleEvent.end_time < last_fixed_event.end_time) {
		flexibleEvent.end_time = last_fixed_event.start_time
		fixedEventListInWhichSearch.splice(fixedEventListInWhichSearch.length - 1, 1)
	}

	// If after the shifts, there is no more space, return a null list
	if (flexibleEvent.end_time - flexibleEvent.start_time < flexibleEvent.duration) {
		return []
	}

	// If there isn't any event, the time slot is the entire flexible event
	if (fixedEventListInWhichSearch.length == 0) {
		return [{ start_time: flexibleEvent.start_time, end_time: flexibleEvent.end_time }]
	}

	// Otherwise, search all the time slots
	for (let i = 0; i < fixedEventListInWhichSearch.length; i++) {
		let possibleTimeSlot = {
			start_time: i == 0 ? flexibleEvent.start_time : fixedEventListInWhichSearch[i].end_time,
			end_time: i == fixedEventListInWhichSearch.length - 1 ? flexibleEvent.end_time : fixedEventListInWhichSearch[i + 1].start_time
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
			let fixedEvents = events.filter((e) => { return !e.duration })
			let flexibleEvents = events.filter((e) => { return e.duration })

			// Check for overlapping fixed events
			let overlapping = overlap(fixedEvents)
			if (overlapping) return res.status(400).end('overlapping: ' + overlapping)

			// Calculate timeSlot for each flexible event and sort them with the fitness function
			for (e of flexibleEvents) {
				e.timeSlots = timeSlots(fixedEvents, e)
			}
			let sortedFlexibleEvents = sortWithFitness(flexibleEvents)

			// Try to fit each flexible event from the less fittable to the most one
			for (e of sortedFlexibleEvents) {
				// Sort time slot from the smallest to the biggest
				e.timeSlots = e.timeSlots.sort((a, b) => {
					return (a.end_time - a.start_time) - (b.end_time - b.start_time)
				})
				// Try to fit in every time slot
				for (t of e.timeSlots) {
					// TODO
				}
			}

			// TODO
		})
	})
})

module.exports = router

if (process.env.ENV == 'testing') {
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