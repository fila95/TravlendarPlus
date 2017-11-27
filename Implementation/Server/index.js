const express = require('express');
const orm = require('orm');
const app = express();

const DB_URL = process.env.DATABASE_URL || "mysql://root:root@localhost/travlendar+";

app.use(orm.express(DB_URL, {
	define: function (db, models, next) {
		db.load("./models", function (err) { if (err) { throw err; } db.sync(); console.log("DB Synced"); next(); })
	}
}));

app.listen(8080, function() {
	console.log("Listening on :8080")
});

app.get("/", function (req, res) {
	console.log(req.models)
});