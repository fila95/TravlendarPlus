const express = require('express')
const router = express.Router()

router.get('/', function (req, res) {
	res.end("hello")
	// TODO
	req.models.events.find({user_token: req.user.user_token})
})

router.post('/', function (req, res) {

})

module.exports = router