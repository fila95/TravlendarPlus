open util/time

abstract sig Bool {}
sig True extends Bool{}
sig False extends Bool{}

sig Location {
  lat: one Int,
  lng: one Int
}

sig Settings {
  transitStart: one Time,
  transitEnd: one Time
}

sig Transit {
}

sig DB {
  users: set User
}

sig User {
  userId: one Int,
  settings: one Settings,
  calendars: set Calendar
}

sig Calendar {
  events: set Event
}

sig Event {
  eventId: one Int,
  start: one Time,
  end: one Time,
  location: lone Location
}

// event ID unique
fact {
  all e1, e2: Event | e1.eventId=e2.eventId implies e1=e2
}

// Each event belong to one and only one calendar
fact {
  all e: Event | e in Calendar.events
  all c1, c2: Calendar, e: Event | e in c1.events and e in c2.events implies c1=c2
}

// Each user belong to one DB
fact {
  all u: User | u in DB.users
}

// Each location belong to one event
fact {
  all l: Location | l in Event.location
}

// ---
// Each calendar belong to one and only one user
fact {
  all c: Calendar | c in User.calendars
  all u1, u2: User, c: Calendar | c in u1.calendars and c in u2.calendars implies u1=u2
}

// Each setting belong to one and only one user
fact {
  all s: Settings | s in User.settings
  all u1, u2: User, s: Settings | s in u1.settings and s in u2.settings implies u1=u2
}

// The beginning of an event must precede its end
fact {
  all e: Event | gt[e.end, e.start]
}

// The beginning of the transitStart must precede transitEnd
fact {
  all s: Settings | gt[s.transitEnd, s.transitStart]
}

// If two events belong to the same calendar, they cannot overlap
fact {
  all e1, e2: Event, c: Calendar | e1!=e2 and e1 in c.events and e2 in c.events
    implies
  gt[e1.start, e2.end] or gt[e2.start, e1.end]
}

// Show
pred show {
  #DB=1
  #users>1 and #users<6
  #User.calendars>0 and #User.calendars<4
  #User.calendars.events>3 and #User.calendars.events<8
}

// Determine if transit are available, based on user settings
pred isTransitAvailable[u: User] {
  all e: Event | e in u.calendars.events
    implies
  gt[e.start, u.settings.transitStart] and lt[e.end, u.settings.transitEnd]

  #DB.users<3
  #u.calendars>0 and #u.calendars.events>0
  #u.calendars<3 and #u.calendars.events<7
}

run show for 8 but 8 Int, exactly 1 DB
run isTransitAvailable for 5 but 8 Int, exactly 1 DB
