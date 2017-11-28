function model(db, cb) {
	db.defineType('coord_lat', {
		datastoreType: function (prop) {
			return 'FLOAT(9,7)'
		}
	});

	db.defineType('coord_lng', {
		datastoreType: function (prop) {
			return 'FLOAT(10,7)'
		}
	});

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
	});

	db.defineType('bit', {
		datastoreType: function (prop) {
			let r = 'BIT(' + (prop.size || 8) + ')'
			if (prop.required) {
				r += ' NOT NULL'
			}
			if (prop.defaultValue) {
				r += ' DEFAULT 0b' + prop.defaultValue
			}
			return r
		}
	});

	db.defineType('transport_mean', {
		datastoreType: function (prop) {
			return "ENUM('WALKING','BIKING','PUBLIC','SHARING','CAR')"
		}
	});

	db.define('users', {
		id: { type: 'serial', required: true, key: true },
		user_token: { type: 'text', size: 24, required: true },
		last_known_position_lat: { type: 'coord_lat' },
		last_known_position_lng: { type: 'coord_lng' },
		updated_at: { type: 'date', time: true, required: true}
	}, {
			hooks: {
				beforeSave: function (next) {
					this.updated_at = new Date()
					return next()
				}
			}
		});

	let Setting = db.define('settings', {
		id: { type: 'serial', required: true, key: true },
		user_id: { type: 'integer', required: true, key: true },
		eco_mode: { type: 'boolean', defaultValue: false, required: true },
		max_walking_distance: { type: 'integer', defaultValue: 2000, required: true },
		max_biking_distance: { type: 'integer', defaultValue: 4000, required: true },
		start_public_transportation: { type: 'time', defaultValue: "07:00:00", required: true },
		end_public_transportation: { type: 'time', defaultValue: "22:00:00", required: true },
		enjoy_enabled: { type: 'boolean', defaultValue: false, required: true },
		car2go_enabled: { type: 'boolean', defaultValue: false, required: true },
		uber_enabled: { type: 'boolean', defaultValue: false, required: true },
		mobike_enabled: { type: 'boolean', defaultValue: false, required: true }
	});

	let Travel = db.define('travels', {
		id: { type: 'serial', required: true, key: true },
		route: { type: 'integer', required: true },
		time: { type: 'integer', required: true },
		transport_mean: { type: 'transport_mean' },
		waypoints: { type: 'text', big: true }
	});

	let Calendar = db.define('calendars', {
		id: { type: 'serial', required: true, key: true },
		user_id: { type: 'integer', required: true },
		name: { type: 'text', size: 255, required: true, defaultValue: '' },
		color: { type: 'text', size: 6, required: true, defaultValue: '' }
	});

	let Company = db.define('companies', {
		id: { type: 'serial', required: true, key: true },
		phone_number: { type: 'text', size: 32, unique: true },
		content: { type: 'text', big: true },
		url_redirect: { type: 'text', big: true },
		company_name: { type: 'text', size: 64, required: true, unique: true }
	});

	let Device = db.define('devices', {
		id: { type: 'serial', required: true, key: true },
		user_id: { type: 'integer', required: true },
		access_token: { type: 'text', size: 32, required: true },
		push_token: { type: 'text', big: true },
		device_type: { type: 'text', size: 32 }
	});

	let Event = db.define('events', {
		id: { type: 'serial', required: true, key: true },
		title: { type: 'text', size: 255, required: true },
		address: { type: 'text', size: 511 },
		lat: { type: 'coord_lat' },
		lng: { type: 'coord_lng' },
		start_time: { type: 'date', required: true, time: true },
		end_time: { type: 'date', required: true, time: true },
		duration: { type: 'integer' },
		repetitions: { type: 'bit', size: 7, required: true, defaultValue: '0000000', required: true },
		calendar_id: { type: 'integer', required: true },
		transports: { type: 'bit', size: 5, required: true, defaultValue: '11111', required: true },
		suggested_start_time: { type: 'date', required: false, time: true },
		suggested_end_time: { type: 'date', required: false, time: true }
	})

	Event.hasMany('travels', Travel);

	return cb()
}

module.exports = model