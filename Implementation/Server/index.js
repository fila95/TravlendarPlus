const express = require('express')
const bodyParser = require('body-parser')
const orm = require('orm')
const app = express()

app.set('port', process.env.PORT || 8080)
app.set('DB_URL', process.env.DATABASE_URL || "postgresql://postgres:postgres@localhost/travlendarplus")
    //app.set('DB_URL', process.env.DATABASE_URL || "postgres://lhmreztgnyprlm:1298fc445f5535201fe6934c7bc200321c2c07c0effa0d07d9fbfc04240b67ee@ec2-46-51-187-253.eu-west-1.compute.amazonaws.com:5432/da7thh5a5r6679?ssl=true")

// Middleware that will log all the requests on the stdout.
// ONLY FOR DEBUG PURPOSE
let logger = (req, res, next) => {
    /* istanbul ignore if  */
    if (process.env.DEBUG) {
        console.log(new Date().toISOString() + " " + req.statusCode + " " + req.method + " " + req.url)
    }
    next()
}

// Load the database schema explained in models.js
let defineDatabase = (db, models, next) => {
    db.load("./models", err => {
        db.sync(err => {
            // copy db.models properties in models
            Object.assign(models, db.models)
            app.emit('db_connected', db)
            app.set('db', db)
            next()
        })
    })
}

// Set the middlewares
app.use(bodyParser.urlencoded({ extended: true }))
app.use(bodyParser.json())
app.use(orm.express(app.get('DB_URL'), { define: defineDatabase, debug: true }))
app.use(logger)
app.use(require('./routes'))

// Disable express header
app.disable('x-powered-by')

// If the app was not imported as a library, start the server
/* istanbul ignore if  */
if (require.main === module) {
    let server = app.listen(app.get('port'), () => {
        console.log("Listening on :" + app.get('port'))
    })
} else {
    module.exports = app
}