const express = require('express')
const router = express.Router()

// Return a list of User's Settings
router.get('/', (req, res) => {
    req.models.settings.find({ user_id: req.user.id }).first((err, settings) => {
        res.json(settings).end()
    })
})

// This function accept a Settings object, a list of edits and a list
// of fields with properties name and validate.
// The function iterate over all the fields[x].name, validate the edits with
// the function fields[x].validate passing the value to be validated, and if
// the validate function return true, it applies the edits to the Settings object
let applyEdits = (settings, fields, edits) => {
    let edited = false
    fields.forEach((field) => {
        let new_value = edits[field.name]
        if (field.validate(new_value)) {
            settings[field.name] = new_value
            edited = true
        }
    })
    if (edited) {
        settings.save()
    }
    return edited
}

// Return the date object if the string_time is a valid time
// in the format: HH:mm:ss
// Also H:m:s and hybrids are accepted
// Example valid time: 9:23:12, 19:54:08, 23:59:1
// Example invalid time: 123:45:67, 24:00:00, :10:00
let validateTime = string_time => {
    if (string_time != undefined && string_time.match('([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]')) {
        return new Date(string_time)
    } else {
        return false
    }
}

// Return the integer if valid, or NaN
let validateInt = string_int => {
    return parseInt(string_int)
}

// Return true if string_bool is a boolean, or false otherwise
let isBoolean = string_bool => {
    return typeof(string_bool) === 'boolean'
}

// Edit settings
// If a field is edited, all the updated settings are returned with a 200 status code
// This means that if an error occurred, but at least one field is valid, the status code will be 200
// If no fields are edited, then a 400 status code is returned
router.patch('/', (req, res) => {
    req.models.settings.find({ user_id: req.user.id }).first((err, settings) => {
        fields = [
            { name: 'eco_mode', validate: isBoolean },
            { name: 'max_walking_distance', validate: validateInt },
            { name: 'max_biking_distance', validate: validateInt },
            { name: 'start_public_transportation', validate: validateTime },
            { name: 'end_public_transportation', validate: validateTime },
            { name: 'enjoy_enabled', validate: isBoolean },
            { name: 'car2go_enabled', validate: isBoolean },
            { name: 'uber_enabled', validate: isBoolean },
            { name: 'mobike_enabled', validate: isBoolean }
        ]

        let ok = applyEdits(settings, fields, req.body)

        return ok ? res.json(settings).end() : res.sendStatus(400).end()
    })
})

module.exports = router