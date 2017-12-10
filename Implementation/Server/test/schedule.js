const schedule = require('../routes/schedule.js').testFunctions

describe('Schedule private functions', () => {
	it('sort', () => {
		randomDate = (start, end) => {
			return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
		}

		let eventList = []

		for (let i = 0; i < 100; i++) {
			eventList.push({
				start_time: randomDate(new Date(2017, 0, 1), new Date())
			})
		}

		let sortedDates = schedule.sort(eventList)

		for (let i = 0; i < sortedDates.length - 1; i++) {
			if (sortedDates[i].start_time > sortedDates[i + 1].start_time) {
				throw new Error("Dates not sorted in ascendent order")
			}
		}
	})
})