open util/time

sig Location {
  lat: Int,
  lng: Int
}
/*
sig TransitPath {
  start: Location,
  end: Location,
  number: Int
}*/

sig User {
  userId: String,
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

// Ogni evento appartiene ad almeno un calendario
fact {
  all e: Event, u: User | u->e in calendars.events
}

// Ogni evento non può essere in più calendari
fact {
  all c1, c2: Calendar, e: Event | e in c1.events && e in c2.events implies c1=c2
}

// Ogni calendario appartiene ad un solo utente
fact {
  all u1, u2: User, c: Calendar | c in u1.calendars && c in u2.calendars implies u1=u2
}

// l'inizio di un evento deve precedere la fine
fact {
  all e: Event | gt[e.end, e.start]
}

// FIXME questo fact e il precedente sono in contrapposizione secondo alloy. perche'?
// Eventi nello stesso calendario non possono sovrapporsi
fact {
  all e1, e2: Event, c: Calendar | e1 in c.events and e2 in c.events
    implies
  gt[e1.start, e2.end] or gt[e2.start, e1.end]
}

fact {
  #events>0
}

pred a [u: User] {
}

run a for 5 but 8 Int, exactly 1 String
