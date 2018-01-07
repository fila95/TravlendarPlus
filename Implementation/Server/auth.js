// Middleware that will populate the req.user only if access_token is valid, and
// will truncate the connection with a 401 or 403 error code if access_token is invalid/missing
let auth = (req, res, next) => {
	let access_token = req.get('X-Access-Token')
	if (access_token != undefined) {
		req.models.devices.find({ access_token: access_token }, (err, devices) => {
			if (!err && devices.length == 1) {
				let device = devices[0]
				device.getUser((err, user) => {
					req.user = user
					user.getSettings((err, settings) => {
						req.user.settings = settings[0]
						return next()
					})
				})
			} else {
				res.sendStatus(403).end()
			}
		})
	} else {
		res.sendStatus(401).end()
	}
}

module.exports = auth