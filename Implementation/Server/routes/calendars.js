const express = require('express')
const router = express.Router()

router.get('/calendars', function (req, res) {
	req.models.calendars.find({ user_id: req.user.id }, (err, results) => {
		res.json(results).end()
	})
})

router.post('/', function (req, res) {

})

module.exports = router