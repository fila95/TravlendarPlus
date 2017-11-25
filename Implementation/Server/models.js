module.exports = function (db, cb) {
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

	db.define('user', {
		user_token: {type: 'text', size: 24, required: true},
		last_known_position_lat: { type: 'coord_lat' },
		last_known_position_lng: { type: 'coord_lng' }
	});

	db.define('setting', {
		eco_mode: {type: 'boolean', defaultValue: false},
		max_walking_distance: { type: 'integer', defaultValue: 2000},
		max_biking_distance: { type: 'integer', defaultValue: 4000},
		start_public_transport: { type: 'time', defaultValue: "07:00:00" },
	});

	return cb();
};