// Middleware that will populate the req.user only if access_token is valid
let auth = (req, res, next) => {
	let access_token = req.get('X-Access-Token')
	if (access_token != undefined) {
		req.models.devices.find({ access_token: access_token }, (err, devices) => {
			if (devices.length == 1) {
				let device = devices[0]
				device.getUser((user) => {
					req.user = user
					return next()
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