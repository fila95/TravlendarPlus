const orm = require('orm')

function model(db, cb) {
	/* istanbul ignore next */
	db.defineType('coord_lat', {
		datastoreType: function (prop) {
			return 'NUMERIC(9,7)'
		}
	})
	/* istanbul ignore next */
	db.defineType('coord_lng', {
		datastoreType: function (prop) {
			return 'NUMERIC(10,7)'
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

	// Given an hour returns true if the public transit can be used, false otherwise
	Setting.canUsePublicTransportation = (time) => {
		sec_start_public_transportation = 24 * this.start_public_transportation.split(":")[0] + 60 * this.start_public_transportation.split(":")[1] + this.start_public_transportation.split(":")[2]
		sec_end_public_transportation = 24 * 60 * this.end_public_transportation.split(":")[0] + 60 * this.end_public_transportation.split(":")[1] + this.end_public_transportation.split(":")[2]
		sec_time = 24 * 60 * this.time.split(":")[0] + 60 * this.time.split(":")[1] + this.time.split(":")[2]
		return sec_time >= sec_start_public_transportation && sec_time <= sec_end_public_transportation
	}

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
		suggested_end_time: { type: 'date', time: true }
	})

	Event.findFromToInCalendar = (from, to, calendar_id, cb) => {
		Event.find({ start_time: orm.between(from, to), calendar_id: calendar_id }, cb)
	}

	Calendar.getEventsOfToday = (cb) => {
		let today = new Date()
		let todayPlus24 = new Date(today + 1000 * 60 * 60 * 24)
		Calendar.find({ calendar_id: this.id, start_time: orm.between(today, todayPlus24) }, cb)
	}

	Event.hasMany('travels', Travel)
	Setting.hasOne('user', User, { reverse: 'settings', required: true })
	Device.hasOne('user', User, { reverse: 'devices', required: true })
	Calendar.hasOne('user', User, { reverse: 'calendars', required: true })
	Event.hasOne('calendar', Calendar, { reverse: 'events', required: true })

	return cb()
}

module.exports = model