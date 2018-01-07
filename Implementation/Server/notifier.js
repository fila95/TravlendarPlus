const apn = require('apn')
require('dotenv').config()

if(!process.env.APN_P8) {
	console.log("No APN_P8 set, Notifications will not be send")
	return module.exports = () => {}
}

/* istanbul ignore next */
const apnProvider = new apn.Provider({
	token: {
		key: new Buffer.from(process.env.APN_P8, 'base64'),
		keyId: process.env.APN_KEYID,
		teamId: process.env.APN_TEAMID
	},
	production: false
})

/* istanbul ignore next */
let sendNotification = (user, properties, cb) => {
	properties = properties || { badge: 0, contentAvailable: 1 }
	let note = new apn.Notification(properties)
	note.topic = 'com.giovannifilaferro.TravlendarPlus'
	note.expiry = Math.floor(Date.now() / 1000) + 3600

	if (process.env.DEBUG) console.log("Created Notification: with alert = '" + note.alert + "'")

	user.getDevices().each((device) => {
		if (process.env.DEBUG) console.log("Sending notification to " + device.access_token)
		if (device.push_token) {
			if (process.env.DEBUG) console.log("Using Push Token: " + device.push_token)
			apnProvider.send(note, device.push_token).then((result) => {
				if (process.env.DEBUG) console.log(JSON.stringify(result))
				if (cb) { cb(result) }
			})
		} else {
			if (process.env.DEBUG) console.log("Cannot send notification, no push token in the db")
		}
	})
}

module.exports = sendNotification