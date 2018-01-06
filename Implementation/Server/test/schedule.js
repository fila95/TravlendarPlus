const app = require('../index')
const schedule = require('../routes/schedule.js').testFunctions
const request = require('supertest')
const polyline = require('polyline')

describe('Schedule private functions', () => {
	let user, device, customEvent
	before(() => {
		user = app.get('testData').user
		device = app.get('testData').device
		customEvent = app.get('testData').event
	})

	let randomDate = (start, end) => {
		return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
	}

	let genRandomEvents = (n, start, end) => {
		if (!start || !end) {
			start = new Date(2017, 0, 1)
			end = new Date(2017, 1, 1)
		}

		let eventList = []

		for (let i = 0; i < n; i++) {
			let start_time = randomDate(start, end)
			let end_time = randomDate(start_time, new Date(start_time.getTime() + 1000 * 60 * 60 * 24))
			eventList.push({
				start_time: start_time,
				end_time: end_time
			})
		}

		return eventList
	}

	it('sort on random data', () => {
		let sortedDates = schedule.sort(genRandomEvents(100))

		for (let i = 0; i < sortedDates.length - 1; i++) {
			if (sortedDates[i].start_time > sortedDates[i + 1].start_time) {
				throw new Error('Dates not sorted in ascendent order')
			}
		}
	})

	it('overlap => true', () => {
		// Overlapping events
		let eventList = [{
			id: 1,
			start_time: new Date(2017, 0, 1, 8),
			end_time: new Date(2017, 0, 1, 12)
		}, {
			id: 2,
			start_time: new Date(2017, 0, 1, 13),
			end_time: new Date(2017, 0, 1, 15)
		}, {
			id: 3,
			start_time: new Date(2017, 0, 1, 14),
			end_time: new Date(2017, 0, 1, 18)
		}]

		let overlapping = schedule.overlap(eventList)
		if (!overlapping || overlapping[0] != 2 || overlapping[1] != 3) {
			throw new Error('Events should overlap, but they don\'t')
		}
	})

	it('overlap => false', () => {
		// Overlapping events
		let eventList = [{
			id: 1,
			start_time: new Date(2017, 0, 1, 8),
			end_time: new Date(2017, 0, 1, 12)
		}, {
			id: 2,
			start_time: new Date(2017, 0, 1, 13),
			end_time: new Date(2017, 0, 1, 15)
		}, {
			id: 3,
			start_time: new Date(2017, 0, 1, 15),
			end_time: new Date(2017, 0, 1, 18)
		}]

		let overlapping = schedule.overlap(eventList)
		if (overlapping) {
			throw new Error('Events should not overlap, but they do')
		}
	})

	it('timeSlots on completely random data', () => {
		let flexibleEvent = genRandomEvents(1)[0]
		// Max 1 hour of duration for testing purpose
		flexibleEvent.duration = Math.floor(Math.random() * 60 * 60 * 1000)

		let eventList = genRandomEvents(10, new Date(flexibleEvent.start_time), new Date(flexibleEvent.end_time))

		let timeSlots = schedule.timeSlots(eventList, flexibleEvent)

		// All the time slots need to be a slice of the window of the flexible event
		for (timeSlot of timeSlots) {
			if (timeSlots.start_time < flexibleEvent.start_time || timeSlots.end_time > flexibleEvent.end_time) {
				throw new Error('There is a time slot outside of the flexible event (??)')
			}
		}

		// All time slots can't overlap with themselves
		if (schedule.overlap(timeSlots)) {
			throw new Error('Overlapping time slots')
		}
	})

	it('timeSlots on pseudo-random data', () => {
		let flexibleEvent = genRandomEvents(1)[0]
		// Max 1 hour of duration for testing purpose
		flexibleEvent.duration = Math.floor(Math.random() * 60 * 60 * 1000)

		let eventList = genRandomEvents(10, new Date(flexibleEvent.start_time), new Date(flexibleEvent.end_time))
		eventList.sort((a, b) => b.start_time - a.start_time)[0].start_time = new Date(flexibleEvent.start_time + 1)
		eventList.sort((a, b) => b.end_time - a.end_time).reverse()[0].end_time = new Date(flexibleEvent.end_time + 1)

		let timeSlots = schedule.timeSlots(eventList, flexibleEvent)

		// All the time slots need to be a slice of the window of the flexible event
		for (timeSlot of timeSlots) {
			if (timeSlots.start_time < flexibleEvent.start_time || timeSlots.end_time > flexibleEvent.end_time) {
				throw new Error('There is a time slot outside of the flexible event (??)')
			}
		}

		// All time slots can't overlap with themselves
		if (schedule.overlap(timeSlots)) {
			throw new Error('Overlapping time slots')
		}

		// When no fixed events, return the global timeslot
		timeSlots = schedule.timeSlots([], flexibleEvent)
		if (timeSlots.length != 1 || timeSlots[0].start_time != flexibleEvent.start_time || timeSlots[0].end_time != flexibleEvent.end_time) {
			throw new Error('timeSlots returned when only one fixed event is present is mismatching')
		}
	})

	it('sort with fitness on fixed data', () => {
		let timeSlots = [
			{ start_time: new Date(2017, 0, 1, 8), end_time: new Date(2017, 0, 1, 10) },
			{ start_time: new Date(2017, 0, 1, 14), end_time: new Date(2017, 0, 1, 16) },
			{ start_time: new Date(2017, 0, 1, 18), end_time: new Date(2017, 0, 1, 19) }
		]

		// For simplicity we give an ID, in order to verify after the sorting, but this ID is not used during the process
		let flexibleEvents = [
			{ id: 2, start_time: new Date(2017, 0, 1, 10), end_time: new Date(2017, 0, 1, 18, 30), duration: 1000 * 60 * 60, timeSlots: timeSlots },
			{ id: 1, start_time: new Date(2017, 0, 1, 8), end_time: new Date(2017, 0, 1, 18, 30), duration: 1000 * 60 * 60, timeSlots: timeSlots },
			{ id: 4, start_time: new Date(2017, 0, 1, 10), end_time: new Date(2017, 0, 1, 18, 30), duration: 2 * 1000 * 60 * 60, timeSlots: timeSlots },
			{ id: 3, start_time: new Date(2017, 0, 1, 8), end_time: new Date(2017, 0, 1, 18, 30), duration: 2 * 1000 * 60 * 60, timeSlots: timeSlots }
		]

		let sortedFlexibleEvents = schedule.sortWithFitness(flexibleEvents)
		for (let i = 0; i < sortedFlexibleEvents; i++) {
			if (i - 1 != sortedFlexibleEvents[i].id) {
				throw new Error('Sort with fitness error')
			}
		}
	})


	it('getEventPreviousTo with fixed data', () => {
		// 13th December 2017, 08:00
		let date = new Date(2017, 11, 13, 8)
		let events = [
			{ id: 1, start_time: new Date(2017, 11, 12, 6, 00), end_time: new Date(2017, 11, 13, 4, 30) },
			{ id: 2, start_time: new Date(2017, 11, 13, 7, 00), end_time: new Date(2017, 11, 13, 7, 30) },
			{ id: 3, start_time: new Date(2017, 11, 13, 7, 31), end_time: new Date(2017, 11, 13, 7, 55) },
			{ id: 4, start_time: new Date(2017, 11, 13, 8, 15), end_time: new Date(2017, 11, 13, 9, 45) }
		]

		if (schedule.getEventPreviousTo(events, date).id != 3) {
			throw new Error('getEventPreviousTo failed')
		}
	})

	it('getReliableUserLocation => true and false', () => {
		let loc = schedule.getReliableUserLocation(user, { start_time: new Date() })
		user.last_known_position_lat = 45.121212
		user.last_known_position_lng = 9.121212
		updated_at = new Date()

		loc = schedule.getReliableUserLocation(user, { start_time: new Date() })
		if (loc == null) {
			throw new Error('Reliable location shouldn\'t be null')
		}

		user.updated_at = new Date(2017, 11, 11, 4, 30)
		loc = schedule.getReliableUserLocation(user, { start_time: new Date() })
		if (loc != null) {
			throw new Error('Reliable location should be null since was updated too long time ago')
		}
	})

	it('distance with fixed data', () => {
		let p1 = { lat: 45.478336, lng: 9.228263 }
		let p2 = { lat: 45.464257, lng: 9.190209 }
		let dist = schedule.distance(p1, p2)

		if (dist < 3 || dist >= 4) {
			throw new Error('Distance miscalculated')
		}
	})

	it('isReachablAsTheCrowFlies with fixed data', () => {
		if (!schedule.isReachablAsTheCrowFlies(0.5, 800)) {
			throw new Error('should not be reachable')
		}
		if (schedule.isReachablAsTheCrowFlies(0.5, 700)) {
			throw new Error('should be reachable')
		}
		if (!schedule.isReachablAsTheCrowFlies(3, 1000)) {
			throw new Error('should not be reachable')
		}
		if (schedule.isReachablAsTheCrowFlies(3, 800)) {
			throw new Error('should be reachable')
		}
		if (!schedule.isReachablAsTheCrowFlies(9, 2000)) {
			throw new Error('should not be reachable')
		}
		if (schedule.isReachablAsTheCrowFlies(9, 1500)) {
			throw new Error('should be reachable')
		}
		if (!schedule.isReachablAsTheCrowFlies(35, 2000)) {
			throw new Error('should not be reachable')
		}
		if (schedule.isReachablAsTheCrowFlies(35, 1500)) {
			throw new Error('should be reachable')
		}
		if (!schedule.isReachablAsTheCrowFlies(50, 2000)) {
			throw new Error('should not be reachable')
		}
		if (schedule.isReachablAsTheCrowFlies(50, 1500)) {
			throw new Error('should be reachable')
		}
	})

	it('should parse the transports of a custum event to ["walking", "driving"]', () => {
		let p1 = { lat: 45.464250, lng: 9.190200 }
		let parse = customEvent.parseTransports(schedule.distance(p1, customEvent), user.settings)
		if (parse.length != 2 || parse.indexOf('walking') == -1 || parse.indexOf('driving') == -1) {
			throw Error('The transports parsing is undefined or doesn\'t contains walking and driving: ' + customEvent.transports + ': ' + parse)
		}
	})

	it('should parse the transports of a custum event to ["driving"], since transits are not available at that time', () => {
		let p1 = { lat: 45.464250, lng: 9.190200 }
		customEvent.transports = "B00101"
		user.settings.start_public_transportation = "10:00:00"
		customEvent.start_time = new Date(2017, 11, 4, 2, 0)

		let parse = customEvent.parseTransports(schedule.distance(p1, customEvent), user.settings)
		if (parse.length != 1 || parse.indexOf('driving') == -1) {
			throw Error('The transports parsing is undefined or doesn\'t contains driving: ' + customEvent.transports + ': ' + parse)
		}
	})
	it('should parse the transports of a custum event to ["transit", "driving"], since the events are too far to each by other means', () => {
		let p1 = { lat: 45.464250, lng: 8.190200 }
		customEvent.transports = "B11111"
		user.settings.start_public_transportation = "10:00:00"
		user.settings.end_public_transportation = "17:00:00"
		customEvent.start_time = new Date(2017, 11, 4, 11, 0)
		let parse = customEvent.parseTransports(schedule.distance(p1, customEvent), user.settings)
		if (parse.length != 2 || parse.indexOf('transit') == -1 || parse.indexOf('driving') == -1) {
			throw Error('The transports parsing is undefined or events are actually reachable by walk/bike: ' + customEvent.transports + ': ' + parse)
		}
	})

	it('eventIsReachable with onlyBasicChecks', async () => {
		let p1 = {
			lat: 45.478336,
			lng: 9.228263,
			start_time: new Date(2017, 11, 12, 8, 0),
			end_time: new Date(2017, 11, 12, 18, 0),
			duration: 1000 * 60 * 60
		}
		let p2 = {
			lat: 45.464257,
			lng: 9.190209,
			start_time: new Date(2017, 11, 12, 8, 0),
			end_time: new Date(2017, 11, 12, 18, 0),
			duration: 1000 * 60 * 60
		}
		let p3 = {
			lat: 45.464257,
			lng: 9.190209,
			start_time: new Date(2017, 11, 12, 8, 0),
			end_time: new Date(2017, 11, 12, 9, 16),
			duration: 1000 * 60 * 60
		}

		// Should be reachable in time
		let res = await schedule.eventIsReachable(p1, p2, { onlyBasicChecks: true })
		if (res != true) {
			throw new Error('p2 should be reachable from p1')
		}

		// Shouldn't be reachable in time, because as the crow flies we need at least 17 min
		res = await schedule.eventIsReachable(p1, p3, { onlyBasicChecks: true })
		if (res != false) {
			throw new Error('p3 should not be reachable from p1')
		}

		// eventIsReachable should throw an error if arguments are invalid
		let err = new Error('test fail')
		try {
			await schedule.eventIsReachable(undefined, {})
			throw err
		} catch (e) {
			if (e == err) {
				throw e
			}
		}
	})

	it('eventIsReachable with all the checks, google included, should return an array of routes', async () => {
		let p1 = { lat: 45.478336, lng: 9.228263 }
		customEvent.lat = 45.464257
		customEvent.lng = 9.190209
		customEvent.start_time = new Date(2017, 11, 12, 8, 0)
		customEvent.end_time = new Date(2017, 11, 12, 9, 40)
		customEvent.duration = 1000 * 60 * 60

		let responses = await schedule.eventIsReachable(p1, customEvent, { settings: user.settings })

		// Google routes have all the copyrights field
		
		for (response_n in responses) {
			response = responses[response_n].response
			for (route_n in response) {
				resp = response[route_n]
				if (!resp.copyrights) {
					throw new Error('No google route returned')
				}
			}
		}

		//for (r in res){
		//console.log(res[r]['overview_polyline'])
		//console.log(res[r]['legs'])
		//}

	}).timeout(10000); // Google Requests could take a while
	
	it('eventIsReachable with all the checks, google included, should return false', async () => {
		let p1 = { lat: 45.478336, lng: 9.228263 }
		customEvent.lat = 45.464257
		customEvent.lng = 9.190209
		customEvent.start_time = new Date(2017, 11, 12, 8, 0)
		customEvent.end_time = new Date(2017, 11, 12, 9, 20)
		customEvent.duration = 1000 * 60 * 60

		let data = await schedule.eventIsReachable(p1, customEvent, { settings: user.settings })
		// Google routes have all the copyrights field
		if (data != false) {
			throw new Error('Google route returned, but noone expected')
		}

	}).timeout(10000); // Google Requests could take a while
	
	it('basicChecks without any params', (done) => {
		let e = { id: 1, start_time: new Date(2017, 11, 12, 6, 00), end_time: new Date(2017, 11, 13, 4, 30), lat: 45, lng: 9 }

		schedule.basicChecks(user, e, (data) => {
			if (data != true) {
				throw new Error('Basic checks failed')
			}
			done()
		})
	})

	it('basicChecks with user location should retuurn true', (done) => {
		user.last_known_position_lat = 45
		user.last_known_position_lng = 9
		user.updated_at = new Date(2017, 11, 12, 5, 59)

		let e = { id: 1, start_time: new Date(2017, 11, 12, 6, 00), end_time: new Date(2017, 11, 13, 4, 30), duration: 4 * 60 * 60 * 1000, lat: 45, lng: 9 }

		schedule.basicChecks(user, e, (data) => {
			done(data != true ? new Error('Basic checks failed') : null)
		})
	})

	it('basicChecks with user location should return false', (done) => {
		user.last_known_position_lat = 40
		user.last_known_position_lng = 9
		user.updated_at = new Date(2017, 11, 12, 5, 59)

		let e = { id: 1, start_time: new Date(2017, 11, 12, 6, 00), end_time: new Date(2017, 11, 13, 4, 30), lat: 45, lng: 9 }

		schedule.basicChecks(user, e, (data) => {
			done(data == true ? new Error('Basic checks failed') : null)
		})
	})

	it('basicChecks with previous event should return true', (done) => {
		let e = { id: 1, start_time: new Date(2017, 11, 12, 15, 00), end_time: new Date(2017, 11, 13, 4, 30), lat: customEvent.lat + 0.1, lng: customEvent.lng + 0.1 }

		schedule.basicChecks(user, e, (data) => {
			done(data != true ? new Error('Basic checks failed') : null)
		})
	})

	it('basicChecks with previous event should return false', (done) => {
		let e = { id: 1, start_time: new Date(2017, 11, 12, 13, 22), end_time: new Date(2017, 11, 13, 4, 30), lat: 45, lng: 9, calendar_id: customEvent.calendar_id }

		schedule.basicChecks(user, e, (data) => {
			done(data == true ? new Error('Basic checks failed') : null)
		})
	})

	/*it('should return a string of waypoints to inset into DB', () => {
		let p1 = { lat: 45.464250, lng: 8.190200 }
		customEvent.start_time=new Date(2017, 11, 4, 11, 0)
		let parse = customEvent.parseTransports(schedule.distance(p1, customEvent), user.settings)
		if(parse.length!=2 || parse.indexOf('transit')==-1 || parse.indexOf('driving')==-1){
			throw Error('The transports parsing is undefined or events are actually reachable by walk/bike: '+ customEvent.transports+ ': '+parse)
		}
	})*/

	/*
	describe('GET /', () => {
		it('Should call the scheduler', async (done) => {
			request(app)
				.get('/api/v1/schedule/')
				.set('X-Access-Token', 'ilZVQ03cyMmX3/+RhrM1AKUDwLGG4Qtp2dU2WDvt+f/qTMMBePMnbV5r6Dg02vgs')
				.expect(200)
				.end(done)
		})
	})
	*/
})