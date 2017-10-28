open util/time

abstract sig Bool {}
sig True extends Bool{}
sig False extends Bool{}

sig Location {
  lat: one Int,
  lng: one Int
}

/*
sig TransitPath {
  start: Location,
  end: Location,
  number: Int
}*/

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

// ID evento univoco
fact {
  all e1, e2: Event | e1.eventId=e2.eventId implies e1=e2
}

// ---
// Ogni evento appartiene ad uno ed un solo calendario
fact {
  all e: Event | e in Calendar.events
}
fact {
  all c1, c2: Calendar, e: Event | e in c1.events and e in c2.events implies c1=c2
}
// ---

// Ogni utente appartiene ad almeno un db
fact {
  all u: User | u in DB.users
}

// Ogni location appartiene ad almeno un evento
fact {
  all l: Location | l in Event.location
}

// ---
// Ogni calendario appartiene ad uno ed un solo utente
fact {
  all c: Calendar | c in User.calendars
}
fact {
  all u1, u2: User, c: Calendar | c in u1.calendars and c in u2.calendars implies u1=u2
}
// ---

// ---
// Ogni setting appartiene ad uno ed un solo utente
fact {
  all s: Settings | s in User.settings
}
fact {
  all u1, u2: User, s: Settings | s in u1.settings and s in u2.settings implies u1=u2
}
// ---

// l'inizio di un evento deve precedere la fine
fact {
  all e: Event | gt[e.end, e.start]
}

// l'inizio di transit in Setting deve precedere la fine
fact {
  all s: Settings | gt[s.transitEnd, s.transitStart]
}

// Due eventi non possono sovrapporsi temporalmente se sono nello stesso calendario
fact {
  all e1, e2: Event, c: Calendar | e1!=e2 and e1 in c.events and e2 in c.events
    implies
  gt[e1.start, e2.end] or gt[e2.start, e1.end]
}

pred show {
  #DB=1
  #users>1 and #users<6
  #User.calendars>0 and #User.calendars<4
  #User.calendars.events>3 and #User.calendars.events<8
}

// Mezzi di trasporto non disponibili dopo un tempo specificato dalle impostazioni
pred isTransitAvailable[u: User] {
  all e: Event | e in u.calendars.events
    implies
  gt[e.start, u.settings.transitStart] and lt[e.end, u.settings.transitEnd]

  #DB.users<3
  #u.calendars>0 and #u.calendars.events>0
  #u.calendars<3 and #u.calendars.events<7
}

run isTransitAvailable for 5 but exactly 1 DB
