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
  location: lone Location,
  areTransitAvailable: one Bool
}

// Mezzi di trasporto non disponibili dopo un tempo specificato dalle impostazioni
fact {
  all u: User, e: Event | e in u.calendars.events && lt[e.start, u.settings.transitStart] && gt[e.end, u.settings.transitEnd]
    implies
  e.areTransitAvailable=False
}

// ID evento univoco
fact {
  all e1, e2: Event | e1.eventId=e2.eventId implies e1=e2
}

// ---
// Ogni evento appartiene ad uno ed un solo calendario
fact {
  all c1, c2: Calendar, e: Event | e in c1.events && e in c2.events implies c1=c2
}
fact {
  all c: Calendar, e: Event | e in c.events
}
// ---


// ---
// Ogni location appartiene ad almeno un evento
fact {
  all l: Location, e: Event | l in e.location
}
// ---

// ---
// Ogni calendario appartiene ad uno ed un solo utente
fact {
  all u: User, c: Calendar | c in u.calendars
}
fact {
  all u1, u2: User, c: Calendar | c in u1.calendars && c in u2.calendars implies u1=u2
}
// ---

// ---
// Ogni setting appartiene ad uno ed un solo utente
fact {
  all u: User, s: Settings | s in u.settings
}
fact {
  all u1, u2: User, s: Settings | s in u1.settings && s in u2.settings implies u1=u2
}
// ---

// l'inizio di un evento deve precedere la fine
fact {
  all e: Event | gt[e.end, e.start]
}

// Due eventi non possono sovrapporsi temporalmente se sono nello stesso calendario
fact {
  all e1, e2: Event, c: Calendar | e1!=e2 and e1 in c.events and e2 in c.events
    implies
  gt[e1.start, e2.end] or gt[e2.start, e1.end]
}

pred show [u: User] {
  #DB=1
  #users>1
  #u.calendars>0
  #u.calendars.events>0
}

run show for 7
