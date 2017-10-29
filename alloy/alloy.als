open util/time

sig Location {
  lat: one Int,
  lng: one Int
}

sig Settings {
  transitStart: one Time,
  transitEnd: one Time,
  maxWalkingDistance: Int
}

sig DB {
  users: set User
}

sig User {
  userId: one Int,
  settings: one Settings,
  calendars: some Calendar
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

// Planar approximation for simplicity
fun distanceSquare[l1, l2: Location] : Int {
  ((l1.lat - l2.lat).mul[l1.lat - l2.lat] + (l1.lng - l2.lng).mul[l1.lng - l2.lng])
}

// Can walk to the event 'e', accordingly to user settings?
pred canWalkToEvent[currentLocation: Location, e: Event, u: User] {
  #e.location=1
  u.settings.maxWalkingDistance.mul[u.settings.maxWalkingDistance] <= distanceSquare[currentLocation, e.location]
}

pred addEvent [e: Event, c, c1: Calendar] {
  c1.events = c.events + e
}

pred delEvent [e: Event, c, c1: Calendar] {
  c1.events = c.events - e
}

pred testAdd [e: Event, c, c1: Calendar] {
  addEvent[e, c, c1]
  e in c1.events
}

pred testDel [e: Event, c, c1: Calendar] {
  delEvent[e, c, c1]
  e not in c.events
}

run testAdd for 8 but 8 Int, exactly 1 DB
run testDel for 8 but 8 Int, exactly 1 DB
//run show for 8 but 8 Int, exactly 1 DB
//run isTransitAvailable for 5 but 8 Int, exactly 1 DB
