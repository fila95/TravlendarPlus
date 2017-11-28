const express = require('express');
const orm = require('orm');
const app = express();

const DB_URL = process.env.DATABASE_URL || "postgresql://postgres:postgres@localhost/travlendarplus";

app.get("/hello", function (req, res) {
	res.end("hello")
});

if (require.main === module) {
	app.use(orm.express(DB_URL, {
		define: function (db, models, next) {
			db.load("./models", function (err) { if (err) { throw err; } db.sync((err) => {if(err){throw err}}); console.log("DB Synced"); next(); })
		},
		debug: true
	}));

	const port = process.env.PORT || 8080

	app.listen(port, function () {
		console.log("Listening on "+ip+":"+port)
	});
} else {
	module.exports = app
}