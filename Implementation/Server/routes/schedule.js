const app = require('../index')
const express = require('express')
const notifier = require('../notifier')
const router = express.Router()

const token = process.env.GOOGLE_MAPS_TOKEN
/* istanbul ignore if */
if (!token) {
	console.error("------------------------------------------------------------")
	console.error("WARNING: GOOGLE_MAPS_TOKEN not defined, check your .env file")
	console.error("------------------------------------------------------------")
}
const googleMapsClient = require('@google/maps').createClient({ key: token, Promise: Promise });

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
// It can be called with 1 params (the whole fixed event list to be checked)
// or with 2 params (the single fixed event to be checked across the whole list)
// Computational time with 1 params: O(n)
// Computational time with 1 params: O(nlogn)
let overlap = (eventListOrEvent, eventList) => {
	if (eventList == null) {
		eventList = sort(eventListOrEvent)
		for (let i = 0; i < eventList.length - 1; i++) {
			// Since the events are sorted, we can just check one condition
			if (eventList[i].end_time > eventList[i + 1].start_time) {
				return [eventList[i].id, eventList[i + 1].id]
			}
		}
	} else {
		let event = eventListOrEvent
		for (let i = 0; i < eventList.length; i++) {
			// Since this time the events are not sorted, we must use both the conditions
			if (event.end_time > eventList[i].start_time && event.start_time < eventList[i].end_time) {
				return [event.id, eventList[i].id]
			}
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
// The param 'from' could be either a real Fixed Event or a fake one representing the user locaiton, while 'to' is a Flexible Event
// The param opt is an object of options. Up to now, there is only one option: onlyBasicChecks [bool,default=false], userSettings
// it returns:
//	- FALSE if the event is not reachable
//  - TRUE if the event passes the basic checks (and if this option is active)
//  - A dictionary of routes with transports as key and values a set of travels
let eventIsReachable = (from, to, opt) => {
	opt = opt || {}
	if (!from || !to || from.lat == undefined || from.lng == undefined || to.lat == undefined || to.lng == undefined) {
		// If one of the location is not defined, throw an error
		throw new Error("from or to parameter doesn't have lat or lng")
	}

	// timeSlotDuration - flexible event duration
	let availableTime = (to.end_time.getTime() - to.start_time.getTime() - to.duration) / 1000

	return new Promise(async (resolve, reject) => {
		// Step 1: As the Crow Flies
		let dist = distance(from, to)
		let step1 = isReachablAsTheCrowFlies(dist, availableTime)
		// If the event 'to' is not even reachable as the crow flies, return false and don't even try
		// to make some requests to Google Maps
		if (!step1) {
			return resolve(false)
		}
		if (opt.onlyBasicChecks) {
			return resolve(true)
		}

		// Step 2: Google Maps Directions API
		//let parsed_transport = to.parseTransports(dist, opt.settings)
		let parsed_transport = ["walking", "bicycling", "transit", "driving"]
		let responses = []
		let query = {
			origin: from,
			destination: to,
			alternatives: true
		}

		for (transport in parsed_transport) {

			let transport_mode = parsed_transport[transport]

			query.mode = transport_mode
			if (query.mode == 'bicycling') {
				query.mode = 'walking'
			}
			let response = await googleMapsClient.directions(query).asPromise()

			let durations = []
			for (let route of response.json.routes) {
				let duration = 0
				for (let leg of route.legs) {
					duration += leg.duration.value
				}
				durations.push(duration)
			}

			// TODO tenere conto delle ripetizioni


			let googlePreferredDuration = durations[0]
			if (googlePreferredDuration <= availableTime) {
				// Try to use the google preferred route
				to.suggested_start_time = new Date(to.start_time + googlePreferredDuration * 1000)
				to.suggested_end_time = new Date(to.suggested_start_time + to.duration)
				responses.push({
					transport: transport_mode,
					response: response.json.routes
				})
			}
		}
		if (responses.length == 0) {
			resolve(false)
		} else {
			resolve(responses)
		}
	})
}
// Given a stram of JSON text from Google Directions API, 
// extracts the most useful info pre db insertion
let filterUsefulTravelInfo = (directionJSON) => {
	let new_route,new_routes=[],new_step,new_steps,i=0
	for (transport_mean_n in directionJSON) {
		transport_mean = directionJSON[transport_mean_n].transport
		first_route = directionJSON[transport_mean_n].response[0]
		
		new_steps=[]
		for (step_n in first_route.legs[0].steps) {
			step=first_route.legs[0].steps[step_n]
			new_step = {
				duration: step.duration.value,
				transport_mean: step.travel_mode,
				waypoints: step.polyline.points
			}	
			new_steps.push(new_step)		
		}

		new_route = {
			route_id: i,
			steps:new_steps
		}
		new_routes.push(new_route)
		
		
		i++
	}
	return new_routes
}

let basicChecks = (user, event, cb) => {
	user.getAllEventsOfCalendarFromNowOn(event.calendar_id, (err, events) => {
		let fixedEvents = events.filter((e) => { return !e.duration })
		let flexibleEvents = events.filter((e) => { return e.duration })

		// Check for overlapping fixed events
		let overlapping = overlap(event, fixedEvents)
		if (overlapping) return cb(new Error('overlapping: ' + overlapping), false)

		// Basic route check: is reachable as the crow flies
		let prev
		let loc = getReliableUserLocation(user, event)
		user.findPreviousEventTo(event, (err, from) => {
			from = from[0]
			if (from && user.updated_at < from.end_time) {
				// The last event is the most recent known location
				prev = {
					lat: from.lat,
					lng: from.lng
				}
			} else if (loc && loc.lat && loc.lng) {
				// The user location is the most recent known location
				prev = {
					lat: loc.lat,
					lng: loc.lng
				}
			} else {
				return cb(null, true)
			}
			eventIsReachable(prev, event, { onlyBasicChecks: true }).then((e) => {
				return cb(null, e)
			})
		})
	})
}

// Returns null if not reliable, or the location if it is
// updated to at least 30 minutes before the start of the event
let getReliableUserLocation = (user, event) => {
	// Check whether the location is no reliable:
	if (!user.updated_at || user.last_known_position_lat == 0 && user.last_known_position_lng == 0 || new Date(event.start_time) - user.updated_at > 30 * 60 * 1000) return null
	return { lat: user.last_known_position_lat, lng: user.last_known_position_lng }
}

router.get('/', (req, res) => {
	// For each calendar
	req.user.getCalendars().each((err, calendar) => {
		// Get all the events of the current calendar
		req.user.getAllEventsOfCalendarFromNowOn(calendar.id, async (err, events) => {
			let fixedEvents = events.filter((e) => { return !e.duration })
			let flexibleEvents = events.filter((e) => { return e.duration })

			// Check for overlapping fixed events
			let overlapping = overlap(fixedEvents)
			if (overlapping) return res.status(400).end('overlapping: ' + overlapping)

			// Calculate timeSlot for each flexible event and sort them with the fitness function
			for (let e of flexibleEvents) {
				e.timeSlots = timeSlots(fixedEvents, e)
				if (e.timeSlots.length == 0) return res.status(400).end('timeslot length is 0 for event: ' + e.id)
			}

			// From now on, the real scheduler is going on, so we suddenly return a
			// 202 - Accepted status code, and the scheduler will notify the user
			// when the results are ready
			res.status(202).end()

			// Assign a scheduler id to this task.
			// Whenever a new schedule start for the same user, this
			// schedule task will be aborted
			let scheduler_id = Math.random().toString().split(".")[1]
			isScheduling = app.get('isScheduling')
			if (!isScheduling) {
				isScheduling = {}
				app.set('isScheduling', isScheduling)
			}
			isScheduling[req.user.id] = scheduler_id

			let sortedFlexibleEvents = sortWithFitness(flexibleEvents)

			// Try to fit each flexible event from the less fittable to the most one
			for (let e of sortedFlexibleEvents) {
				// Sort time slot from the smallest to the biggest
				e.timeSlots = e.timeSlots.sort((a, b) => {
					return (a.end_time - a.start_time) - (b.end_time - b.start_time)
				})

				// Try to fit in each time slot
				for (let timeSlot of e.timeSlots) {
					// A new scheduler is started with a different id, abort this
					if (isScheduling[req.user.id] != scheduler_id) {
						return
					}

					// Supposing that the event will be placed in this time slot,
					// determine if the event e is reachable
					let prev = getEventPreviousTo(events, timeSlot.start_time)
					let loc = getReliableUserLocation(req.user, prev)

					if (prev == null) {
						// If the previous event is not defined, check the user location
						if (!loc) {
							// If we don't know the user location, insert the event anyway
							e.suggested_start_time = new Date(timeSlot.start_time)
							e.suggested_end_time = new Date(e.suggested_start_time + e.duration)
							return e.save(err => {
								if (err) throw err
							})
						} else if (req.user.updated_at > prev.end_time) {
							// If the last real user position is closer to the end of the previouus event,
							// use that instead of the previous event position
							// Create a fake event that will be used in asking if reachable
							prev = {
								start_time: req.user.updated_at,
								end_time: req.user.updated_at,
								lat: loc.lat,
								lng: loc.lng
							}
						}
						// implicit else: use the previous event position
					}
					// Ask if reachable with await
					// Using async/await, we can loop over an asynchronous function
					// without spawning thousands of async calls
					let routes = await eventIsReachable(prev, e, { settings: req.user.settings })
					if (routes) {
						// TODO: insert them in the db, using:
						// e.addTravels([travel1, travel2, travel3, ...], err => {
						//   if(err) {throw err}
						// })
					}

					return e.save(err => {
						if (err) throw err
					})
				}
			}
		})
	})

	// Finish scheduler for all the events of all the calendars
	// notifier.sendNotification(text, user)
})

module.exports = {
	router: router,
	basicChecks: basicChecks,
	filterUsefulTravelInfo: filterUsefulTravelInfo
}

if (process.env.NODE_ENV == 'testing') {
	module.exports.testFunctions = {
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
		basicChecks: basicChecks,
		eventIsReachable: eventIsReachable
	}
}