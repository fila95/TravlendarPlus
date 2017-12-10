const express = require('express')
const router = express.Router()


/*		for (var i = 0, len = calendars.length; i < len; i++) {

		  	
		  	id=calendars[i]['id']
		  	console.log("ID: "+id)
		  	req.models.events.find({ calendar_id: id }, (err2, events) => {
		  		console.log("ID: "+id)
		  		if(!events){
		  			calendars[i]['calendar_events']=null
		  		}else{
		  			calendars[i]['calendar_events']=null	
		  		} 
		  	})
		}
		*/

// Return a list of User's Calenars
router.get('/', (req, res) => {
	req.models.calendars.find({ user_id: req.user.id }, (err, results) => {
		console.log(results)

		res.json(results).end()
	})
})

module.exports = router