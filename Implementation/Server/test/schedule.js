const app = require('../index')
const schedule = require('../routes/schedule.js').testFunctions

describe('Schedule private functions', () => {
	let user, device
	before(() => {
		user = app.get('testData').user
		device = app.get('testData').device
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
				throw new Error("Dates not sorted in ascendent order")
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
			throw new Error("Events should overlap, but they don't")
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
			throw new Error("Events should not overlap, but they do")
		}
	})

	// TODO timeSlots on fixed data in order to increase test coverage
	it('timeSlots on random data', () => {
		let flexibleEvent = genRandomEvents(1)[0]
		// Max 1 hour of duration for testing purpose
		flexibleEvent.duration = Math.floor(Math.random() * 60 * 60 * 1000)

		let eventList = genRandomEvents(10, new Date(flexibleEvent.start_time), new Date(flexibleEvent.end_time))

		let timeSlots = schedule.timeSlots(eventList, flexibleEvent)

		// All the time slots need to be a slice of the window of the flexible event
		for (timeSlot of timeSlots) {
			if (timeSlots.start_time < flexibleEvent.start_time || timeSlots.end_time > flexibleEvent.end_time) {
				throw new Error("There is a time slot outside of the flexible event (??)")
			}
		}

		// All time slots can't overlap with themselves
		if (schedule.overlap(timeSlots)) {
			throw new Error("Overlapping time slots")
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
				throw new Error("Sort with fitness error")
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
			throw new Error("getEventPreviousTo failed")
		}
	})

	it('Test getReliableUserLocation', () => {
		let loc = schedule.getReliableUserLocation(user)
		user.last_known_position_lat = 45.121212
		user.last_known_position_lng = 9.121212
		updated_at = new Date()

		loc = schedule.getReliableUserLocation(user)
		if (loc == null) {
			throw new Error('Reliable location shouldn\'t be null')
		}
		
		updated_at = new Date(2017, 11, 11, 4, 30)
		loc = schedule.getReliableUserLocation(user)
		if (loc == null) {
			throw new Error('Reliable location should be null since was updated too long time ago')
		}
	})
})