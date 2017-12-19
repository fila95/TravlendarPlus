const express = require('express')
const router = express.Router()

const token = process.env.GOOGLE_MAPS_TOKEN
/* istanbul ignore if */
if (!token) {
	console.error("------------------------------------------------------------")
	console.error("WARNING: GOOGLE_MAPS_TOKEN not defined, check your .env file")
	console.error("------------------------------------------------------------")
}
const googleMapsClient = require('@google/maps').createClient({
	key: token
});

// Suppose that timeSlots are sorted and not overlapping
// Return the time in milliseconds for the given timeSlots
let freeTimeForTimeSlots = (flexibleEvent, timeSlots) => {
	let freeTime = 0
	for (let timeSlot of timeSlots) {
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
	
	// If there isn't any event, the time slot is the entire flexible event
	if (fixedEventListInWhichSearch.length == 0) {
		return [{ start_time: flexibleEvent.start_time, end_time: flexibleEvent.end_time }]
	}

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

// Get the previous event to the given dateTime
let getEventPreviousTo = (events, dateTime) => {
	let prev_event = { end_time: 0 }
	dateTime = new Date(dateTime)
	events.filter(event => {
		return new Date(event.end_time) < dateTime
	}).forEach(event => {
		if (event.end_time > prev_event.end_time) {
			prev_event = event
		}
	})
	return prev_event.end_time == 0 ? null : prev_event
}

// Return the distance from the point p1 to p2, in kilometers, with the haversine formule
let distance = (p1, p2) => {
	// p = Math.PI / 180, used for the conversion
	var p = 0.017453292519943295
	var cos = Math.cos
	var d = 0.5 - cos((p2.lat - p1.lat) * p) / 2 + cos(p1.lat * p) * cos(p2.lat * p) * (1 - cos((p2.lng - p1.lng) * p)) / 2
	// 12742 = 2 * R; R = 6371 km
	return 12742 * Math.asin(Math.sqrt(d))
}

// Return true if the distance can be covered in less than time, with avearage fixed speeds
// Distance is in km, time is in sec
let isReachablAsTheCrowFlies = (distance, time) => {
	if (distance < 1) {
		speed = 2.5
	} else if (distance < 5) {
		speed = 12
	} else if (distance < 12) {
		speed = 18
	} else if (distance < 50) {
		speed = 70
	} else {
		speed = 100
	}
	// distance is in km
	// speed is in km/h
	// time is in sec
	return distance / speed < time / 60.0 / 60.0
}

// If the event is reachable from coord,
// it returns the routes and sets the suggested_start_time/suggested_end_time, otherwise it returns false
// The params from is a Fixed Event and to is a Flexible Event
// The param opt is an object of options. Up to now, there is only one option: onlyBasicChecks [bool,default=false]
let eventIsReachable = (from, to, opt) => {
	opt = opt || {}
	if (!from || !to || from.lat == undefined || from.lng == undefined || to.lat == undefined || to.lng == undefined) {
		// If one of the location is not defined, throw an error
		throw new Error("from or to parameter doesn't have lat or lng")
	}

	// timeSlotDuration - flexible event duration
	let availableTime = (to.end_time - to.start_time - to.duration) / 1000

	return new Promise((resolve, reject) => {
		// Step 1: As the Crow Flies
		let dist = distance(from, to)
		let step1 = isReachablAsTheCrowFlies(dist, availableTime)
		// If the event 'to' is not even reachable as the crow flies, return false and don't even try
		// to make some requests to Google Maps
		if (!step1) {
			return resolve(false)
		}
		if(opt.onlyBasicChecks) {
			return resolve(true)
		}

		// Step 2: Google Maps Directions API
		let query = {
			origin: from,
			destination: to,
			alternatives: true
		}
		googleMapsClient.directions(query, (err, response) => {
			let durations = []
			for (let route of response.json.routes) {
				let duration = 0
				for (let leg of route.legs) {
					duration += leg.duration.value
				}
				durations.push(duration)
			}

			let googlePreferredDuration = durations[0]
			
			if (googlePreferredDuration <= availableTime) {
				// Try to use the google preferred route
				to.suggested_start_time = new Date(to.start_time + googlePreferredDuration * 1000)
				to.suggested_end_time = new Date(to.suggested_start_time + to.duration)
				resolve(response.json.routes[0])
			} else {
				// No route with less time travel than timeNeeded
				resolve(false)
			}
		})
	})
}

// Returns null if not reliable, or the location if it is
let getReliableUserLocation = user => {
	//checking whether the location is no reliable
	if (!user.updated_at || new Date() - user.updated_at > 30 * 60 * 1000) return null
	return user.updated_at
}

router.post('/', (req, res) => {
	// For each calendar
	req.user.getCalendars().each((err, calendar) => {
		// Get all the events of today from the current calendar
		calendar.getEventsOfToday(async (err, events) => {
			let fixedEvents = events.filter((e) => { return !e.duration })
			let flexibleEvents = events.filter((e) => { return e.duration })

			// Check for overlapping fixed events
			let overlapping = overlap(fixedEvents)
			if (overlapping) return res.status(400).end('overlapping: ' + overlapping)

			// Calculate timeSlot for each flexible event and sort them with the fitness function
			for (let e of flexibleEvents) {
				e.timeSlots = timeSlots(fixedEvents, e)
			}
			let sortedFlexibleEvents = sortWithFitness(flexibleEvents)

			// Try to fit each flexible event from the less fittable to the most one
			for (let e of sortedFlexibleEvents) {
				// Sort time slot from the smallest to the biggest
				e.timeSlots = e.timeSlots.sort((a, b) => {
					return (a.end_time - a.start_time) - (b.end_time - b.start_time)
				})

				// Try to fit in each time slot
				for (let timeSlot of e.timeSlots) {
					// Supposing that the event will be placed in this time slot,
					// determine if the event e is reachable

					let prev = getEventPreviousTo(events, timeSlot.start_time)
					if (prev == null) {
						// If the previous event is not defined, check the user location
						let loc = getReliableUserLocation(req.user)
						if (!loc) {
							// If we don't know the user location, insert the event anyway
							e.suggested_start_time = new Date(timeSlot.start_time)
							e.suggested_end_time = new Date(e.suggested_start_time + e.duration)
							return e.save(err => {
								if(err) throw err
							})
						} else {
							// Create a fake event that will be used in asking if reachable
							prev = {
								start_time: req.user.updated_at,
								end_time: req.user.updated_at,
								lat: loc.lat,
								lng: loc.lng
							}
						}
					}
					// Ask if reachable with await
					// Using async/await, we can loop over an asynchronous function
					// without spawning thousands of async calls
					let result = await eventIsReachable(prev, e)
					return e.save(err => {
						if(err) throw err
					})
				}
			}
		})
	})
})

module.exports = router

if (process.env.NODE_ENV == 'testing') {
	router.testFunctions = {
		timeSlots: timeSlots,
		overlap: overlap,
		sort: sort,
		sortWithFitness: sortWithFitness,
		fitness: fitness,
		occupiedTimeForTimeSlots: occupiedTimeForTimeSlots,
		freeTimeForTimeSlots: freeTimeForTimeSlots,
		getEventPreviousTo: getEventPreviousTo,
		getReliableUserLocation: getReliableUserLocation,
		distance: distance,
		isReachablAsTheCrowFlies: isReachablAsTheCrowFlies,
		eventIsReachable: eventIsReachable
	}
}