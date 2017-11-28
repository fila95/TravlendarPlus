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
			return 'TIME'
		}
	});
	db.defineType('transport_mean', {
		datastoreType: function (prop) {
			return "ENUM('WALKING','BIKING','PUBLIC','SHARING','CAR')"
		}
	});

	db.define('user', {
		id: {type: 'integer', size: 11, required: true, key: true},
		user_token: {type: 'text', size: 24, required: true},
		last_known_position_lat: { type: 'coord_lat' },
		last_known_position_lng: { type: 'coord_lng' },
		updated_at: { type: 'date', time: true }
	}, {
		hooks: {
			beforeSave: function(next) {
				this.updated_at = new Date()
				return next()
			}
		}
	});

	let Setting=db.define('setting', {
		id: {type: 'integer', size: 11, required: true, key: true},
		user_id: {type: 'integer', size: 11, required: true, key: true},
		eco_mode: {type: 'boolean', defaultValue: false},
		max_walking_distance: { type: 'integer', size: 11, defaultValue: 2000},
		max_biking_distance: { type: 'integer', size: 11, defaultValue: 4000},
		start_public_transport: { type: 'time', defaultValue: "07:00:00" },
		end_public_transport: { type: 'time', defaultValue: "22:00:00" },
		enjoy_enabled: { type: 'boolean', defaultValue: false, required: true },
		car2go_enabled: { type: 'boolean', defaultValue: false, required: true },
		uber_enabled: { type: 'boolean', defaultValue: false, required: true },
		mobike_enabled: { type: 'boolean', defaultValue: false, required: true }
	});

	db.define('events_travel', {
		id: {type: 'integer', size: 11, required: true, key: true},
		travel_id: {type: 'integer', size: 11, required: true, key: true}
	})

	let Travel=db.define('travel', {
		id: {type: 'integer', size: 11, required: true, key: true},
		route: {type: 'integer', size: 11, required: true},
		time: {type: 'integer', size: 11, required: true},
		transport_mean: {type: 'transport_mean', required: false}
	});

	let Calendar=db.define('calendar', {
		id: {type: 'integer', size: 11, required: true, key: true},
		user_id: {type: 'integer', size: 11, required: true},
		name: {type: 'text', size: 255, required: true, defaultValue:'' },
		color: {type: 'text', size: 6, required: true, defaultValue:'' }		
	});

	let Company=db.define('company', {
		id: {type: 'integer', size: 11, required: true, key: true},
		phone_number: {type: 'text', size: 32, required: false},
		content: {type: 'text'},
		url_redirect: {type: 'text'},
		company_name: {type: 'text', size: 64, required: false}	
	});

	let Device=db.define('device', {
		id: {type: 'integer', size: 11, required: true, key: true},
		user_id: {type: 'integer', size: 11, required: true},
		access_token: {type: 'text', size: 32, required: false},
		push_token: {type: 'text'},
		device_type: {type: 'text', size: 32, required: false}	
	});

	let Event=db.define('event', {
		id: {type: 'integer', size: 11, required: true, key: true},
		title: {type: 'text', size: 255, required: true},
		address: {type: 'text', size: 511, required: false},
		lat: { type: 'coord_lat', required: false },
		long: { type: 'coord_lng', required: false },
		start_time: {type: 'date', required: true, time: true},
		end_time: {type: 'date', required: true, time: true},
		duration: {type: 'integer', size: 11, required: false},
		repetitions: {type: 'binary', size: 7, required: true, defaultValue:'0000000'},
		calendar_id: {type: 'integer', size: 11, required: true},
		transports: {type: 'binary', size: 5, required: true, defaultValue:'1111111'},
		suggested_start_time: {type: 'date', required: false, time: true},
		suggested_end_time: {type: 'date', required: false, time: true}
	})
	.hasMany('travel', Travel, { reverse: 'event', key: true });

	return cb()
}

module.exports = model