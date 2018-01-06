const apn = require('apn')

/* istanbul ignore next */
const notifier = () => {
	const apnProvider = new apn.Provider({
		token: {
			key: new Buffer.from(process.env.APN_P8, 'base64'),
			keyId: process.env.APN_KEYID,
			teamId: process.env.APN_TEAMID
		},
		production: process.env.NODE_ENV == 'production'
	})

	let sendNotification = (text, user) => {
		let note = new apn.Notification()
		note.topic = 'com.giovannifilaferro.TravlendarPlus'
		note.expiry = Math.floor(Date.now() / 1000) + 3600
		note.badge = 1
		note.alert = text

		user.getDevices().each((device) => {
			console.log("Sending notification to " + device)
			if(device.push_token) {
				console.log("Using Push Token: " + device.push_token)
				apnProvider.send(note, device.push_token).then((result) => {
					console.log(JSON.stringify(result))
				})
			} else {
				console.log("Cannot send notification, no push token in the db")
			}
		})
	}
}

module.exports = notifier