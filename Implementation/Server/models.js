const orm = require('orm')

function model(db, cb) {
	/* istanbul ignore next */
	db.defineType('coord_lat', {
		datastoreType: function (prop) {
			return 'NUMERIC(9,7)'
		},
		valueToProperty: function (value, prop) {
			if (value instanceof Number) {
				return value
			} else {
				return Number(value)
			}
		}
	})
	/* istanbul ignore next */
	db.defineType('coord_lng', {
		datastoreType: function (prop) {
			return 'NUMERIC(10,7)'
		},
		valueToProperty: function (value, prop) {
			if (value instanceof Number) {
				return value
			} else {
				return Number(value)
			}
		}
	})

	/* istanbul ignore next */
	db.defineType('time', {
		datastoreType: function (prop) {
			let r = 'TIME'
			if (prop.required) {
				r += ' NOT NULL'
			}
			if (prop.defaultValue) {
				r += ' DEFAULT \'' + prop.defaultValue + '\''
			}
			return r
		}
	})

	/* istanbul ignore next */
	db.defineType('bit', {
		datastoreType: function (prop) {
			let r = 'BIT(' + (prop.size || 8) + ')'
			if (prop.required) {
				r += ' NOT NULL'
			}
			if (prop.defaultValue) {
				r += ' DEFAULT B\'' + prop.defaultValue + '\''
			}
			return r
		}
	})

	// Create the enum on a postgresql instance
	db.driver.execQuery("CREATE TYPE transport_mean_type AS ENUM ('WALKING','BIKING','PUBLIC','SHARING','CAR')", (err, data) => { })

	/* istanbul ignore next */
	db.defineType('transport_mean', {
		datastoreType: function (prop) {
			return "transport_mean_type"
		}
	})

	let User = db.define('users', {
		user_token: { type: 'text', size: 24, required: true },
		last_known_position_lat: { type: 'coord_lat', defaultValue: 0 },
		last_known_position_lng: { type: 'coord_lng', defaultValue: 0 },
		updated_at: { type: 'date', time: true }
	}, {
			hooks: {
				beforeSave: function (next) {
					this.updated_at = new Date()
					return next()
				}
			},
			methods: {
				findPreviousEventTo: (event, cb) => {
					Event.find({ calendar_id: event.calendar_id, end_time: orm.lte(event.start_time) }, {}, 1, 'end_time', cb)
				},
				getAllEventsOfCalendarFromNowOn: (calendar_id, cb) => {
					Event.find({ calendar_id: calendar_id, start_time: orm.gte(new Date()) }, cb)
				}
			}
		})

	let Setting = db.define('settings', {
		eco_mode: { type: 'boolean', defaultValue: false },
		max_walking_distance: { type: 'integer', defaultValue: 2000 },
		max_biking_distance: { type: 'integer', defaultValue: 4000 },
		start_public_transportation: { type: 'time', defaultValue: "07:00:00" },
		end_public_transportation: { type: 'time', defaultValue: "22:00:00" },
		enjoy_enabled: { type: 'boolean', defaultValue: false },
		car2go_enabled: { type: 'boolean', defaultValue: false },
		uber_enabled: { type: 'boolean', defaultValue: false },
		mobike_enabled: { type: 'boolean', defaultValue: false }
	})

	let Travel = db.define('travels', {
		route: { type: 'integer', required: true },
		time: { type: 'integer', required: true },
		transport_mean: { type: 'transport_mean' },
		waypoints: { type: 'text', big: true }
	})

	let Calendar = db.define('calendars', {
		name: { type: 'text', size: 255, required: true },
		color: { type: 'text', size: 6, required: true }
	})

	let Company = db.define('companies', {
		phone_number: { type: 'text', size: 32, unique: true },
		content: { type: 'text', big: true },
		url_redirect: { type: 'text', big: true },
		company_name: { type: 'text', size: 64, required: true, unique: true }
	})

	let Device = db.define('devices', {
		access_token: { type: 'text', size: 32, required: true },
		push_token: { type: 'text', big: true },
		device_type: { type: 'text', size: 32 }
	})

	let Event = db.define('events', {
		title: { type: 'text', size: 255, required: true },
		address: { type: 'text', size: 511 },
		lat: { type: 'coord_lat', required: true },
		lng: { type: 'coord_lng', required: true },
		start_time: { type: 'date', required: true, time: true },
		end_time: { type: 'date', required: true, time: true },
		duration: { type: 'integer' },
		repetitions: { type: 'bit', size: 7, defaultValue: '0000000' },
		transports: { type: 'bit', size: 5, defaultValue: '11111' },
		suggested_start_time: { type: 'date', time: true },
		suggested_end_time: { type: 'date', time: true },
		reachable: { type: 'boolean', defaultValue: true }
	}, {
			methods: {
				// Parsing the transports from binary encoding. Example: 11000 -> ["walking","bicycling"]
				// Given a list of already parsed transpors (list of strings of transports), it returns 
				// the same list of strings without means of transportation that the user 
				// can't travel with, depending on settings and time
				parseTransports: function (distance, settings) {
					let sTransports = ["walking", "bicycling", "transit", "sharing", "driving"]
					let transports = this.transports
					let mask = transports.split('').map(transport => transport == 1)
					sTransports = sTransports.filter((transport, index) => mask[index])

					//Checking walking distance
					if (sTransports.indexOf('walking') != -1 && distance * 1000 > settings.max_walking_distance) {
						sTransports.splice(sTransports.indexOf('walking'), 1)
					}

					//Checking bicycling distance
					if (sTransports.indexOf('bicycling') != -1 && distance * 1000 > settings.max_biking_distance) {
						sTransports.splice(sTransports.indexOf('bicycling'), 1)
					}

					// Dropping the sharing (forseen at version 2 of the app)
					if (sTransports.indexOf('sharing') != -1) {
						sTransports.splice(sTransports.indexOf('sharing'), 1)
					}

					//Checking if the time allows to use transits
					if (sTransports.indexOf('transit') != -1) {
						let min_start_event = this.start_time.getHours() * 60 + this.start_time.getMinutes()
						min_start_transit = parseInt(settings.start_public_transportation.split(':')[0]) * 60 + parseInt(settings.start_public_transportation.split(':')[1])
						min_end_transit = parseInt(settings.end_public_transportation.split(':')[0]) * 60 + parseInt(settings.end_public_transportation.split(':')[1])
						if (min_start_event > min_end_transit || min_start_event < min_start_transit) {
							sTransports.splice(sTransports.indexOf('transit'), 1)
						}
					}

					return sTransports
				}
			}
		})

	Event.hasMany('travels', Travel, {}, { key: true })
	Setting.hasOne('user', User, { reverse: 'settings', required: true })
	Device.hasOne('user', User, { reverse: 'devices', required: true })
	Calendar.hasOne('user', User, { reverse: 'calendars', required: true })
	Event.hasOne('calendar', Calendar, { reverse: 'events', required: true })

	return cb()
}

module.exports = model