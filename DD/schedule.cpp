#include <stdlib.h>
#include <ctime>

/*

registrazione/login impliciti
CRUD calendario + eventi + impostazioni
retrieve info - calendari - eventi - schedule

scheduler, chiamato quando avviene:
	- l'aggiunta/modifica di un evento
	- ogni X tempo per utente (variabile in base numero utenti)
	- ogni modifica di posizione dell'utente

Lo schedule controlla:
	- eventi che non si overlappino temporalmente e che siano raggiungibili con i mezzi specificati nell'evento:
		* se l'evento è il primo della giornata, la prima posizione è quella dell'utente, altrimenti è quella dell'evento precedente.
		  Un evento è raggiungibile sse tempoPerPercorrere(posizione1, posizione2) < evento.start-(now or eventoPrecedente.end)
		  Quindi se un evento non è raggiungibile, allora non è schedulabile, e viene segnalato il warning all'utente
		  I means of transportation disponibili vengono scelti in base alle settings, e per ogni mezzo disponibile viene fatta
		    una richiesta a google maps directions api, e viene scelta quella con tempo minimo

*/



// ****** DATA CLASSES

enum TransportMean {
    walk,
    bike,
    public_transportation,
    ride,
    car
}

enum EventTiming {
    past,
    running,
    future
}


class Transportation {

    int time; // In minutes
    TransportMean transport;
    vector<Coordinates> waypoints;
    
}

class Route {

    vector<Transportation> transportations;

}

class Coordinates {

    float lat;
    float lng;

}

class Settings {

    int id;
    bool eco_mode;

    int max_walking_distance;
    int max_biking_distance;

    unsigned long start_public_transportation;
    unsigned long end_public_transportation;
    
    User *user;

}

class Event {

    int id;
    string title;
    string address;

    Coordinates coords;

    // time
    unsigned long start;
    unsigned long end;
    int duration;
    unsigned long suggested_start;  // not present in server database, just sent to client
    unsigned long suggested_end;    // not present in server database, just sent to client
    
    byte repetitions;               // MSB 0, the others should be used as booleans for each weekday
    bool[5] transports;

    vector<Route> routes;           // not present in server database, just sent to client

    Calendar *calendar;

}

class Calendar {

    int id;
    string name;
    string color;

    vector<Event> events;

    User *user;

}

class Device {

    int id;
    string access_token;
    string push_token;
    string device_type;

    User *user;

}

class User {

    int id;
    string user_id;

    vector<Calendar> calendars;
    vector<Device> devices;

    Coordinates last_known_position;

    Setting settings;

}

class Schedule {

    unsigned long update_time;
    vector<Event>* schedule;

}



// Schedule function that checks the next hours, this can be called when user uploads his current position or the system calls it every 2 hours
Schedule* schedule(User *u) {
    // Schedule from now to tomorrow
    return schedule(u, now(), start_of_today() + 86400);
}

// Schedule function that checks just the 12 hours before and after the event as parameter that has been created, modified or deleted
Schedule* schedule(User *u, Event *e) {
    // Schedule 12 hours before and after the event is created
    if (e.repetitions || 0x0111111) {
        Schedule *scheduled = new Schedule();
        
        for each(unsigned long day in daysNeedingReschedule(u, e)) {
            Schedule *e = schedule(u, day, day + 86400);
            appendSchedule(scheduled, e);
        }

        return scheduled;
    }
    else {
        return schedule(u, e.start - 43200, e.start + 43200);
    }
}

// Schedule an entire date interval, this can be called from the other schedule functions
Schedule* schedule(User *u, unsigned long date1, unsigned long date2) {
    Schedule *s = new Schedule();
    s->update_time = now();
    vector<Event> *scheduled = new vector<Event>();
    s->schedule = scheduled;


    // Check for each user's calendar overlapping and reachability
    for each(Calendar *c in u.calendars) {

        // Get all the events on the calendar between that dates
        vector<Event> *events = getCalendarEventsInRange(c, d1, d2);
    
        // Ensure events does not overlap
        if (overlap(events)) {
            vector<Event> *overlapping = overlappingEvents(events);
            notifyOverlapping(u, overlapping);
            break;
        }
    
        // Now we need to make sure that each event is reachable

        int s = events->size();
        int count = 0;
        for (count = 0; count < s; count++) {
            
            // Exit if inspecting last event
            if (count == s-1) {
                break;
            }

            if (eventIsToday(events[count])) {
                // It's today

                switch (eventTiming(events[count])) {

                    case past:
                        // We don't care about
                    break;

                    case running:

                    break;

                    case future:

                    break;

                    default:
                    break;

                }

                if (eventIsFirstOfDay(events[count], c)) {
                    // Check if reachable based on my current position
                }
            }
            else {
                // It's not today so just check the events separatedly

                
            }


        }

    }

    return s;

}


// ******** Utilities

// Returns current timestamp
unsigned long now();

// Returns today's start timestamp
unsigned long start_of_today();

// Returns timestamp of the start of the day of a given timestamp
unsigned long start_of_day(unsigned long time);

// Foreach day in which events that are not e exist returns an array of dates in which schedule function should be called
vector<unsigned long> daysNeedingReschedule(User *u, Event *e);

// ******** Events

// Given a set of events returns whether these overlaps
bool overlap(vector<Event> *events);

// Given a set of events returns an array of overlapping events if they exist
vector<Event>* overlappingEvents(vector<Event> *events);

// Returns a set of Calendar's events between some dates ordered by startdate.
vector<Event>* getCalendarEventsInRange(Calendar *calendar, Date d1, Date d2);

// Returns true if the event is today
bool eventIsToday(Event *e);

// Returns true if this event is scheduled as first of the day
bool eventIsFirstOfDay(Event *e, Calendar *c);

// Check if an event is reachable from specific coordinates
bool eventIsReachable(Coordinates coords, Event *e);

// Check if an event e2 is reachable from previous event e1
bool eventIsReachable(Event *e1, Event *e2);

// Check if in a given set of events, flexible events are present
bool containsFlexibleEvents(vector<Event> *events);

// Get timing informations about the event
EventTiming eventTiming(Event *event);

// Returns a set of flexible events if they are contained in the given set
vector<Event>* flexibleEvents(vector<Event> *events);

// ******** Schedule
// Appends a schedule to an existing one
Schedule* appendSchedule(Schedule *s1, Schedule *s2);


// ********* Notifications
// Sends back a notifications
void notifyOverlapping(User *u, vector<Event> *events);
void notifyUnreachable(User *u, vector<Event> *events);
void notifyUnreachable(User *u, Event* event);