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

// ****** Utility

struct TimeSlot {
    unsigned long start;
    unsigned long end;
}

enum TransportMean {
    walk,
    bike,
    public_transportation,
    ride,
    car
}

// ****** DATA CLASSES

class Transportation {

    int time; // In minutes
    TransportMean transport;
    vector<Coordinates> waypoints;
    
}

class Route {

    vector<Transportation> *transportations;

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

        // Get all the events on the calendar between that dates making sure they are all now or in the future
        vector<Event> *events = getCalendarEventsInRange(c, d1, d2);
        events = nextEvents(events);
        resetEvents(events);
        
        // Ensure events does not overlap
        if (overlap(events)) {
            vector<Event> *overlapping = overlappingEvents(events);
            notifyOverlapping(u, overlapping);
            break;
        }


        // Just filter events ordering them based on filterEvent() rules
        vector<Event> *fixed;
        vector<Event> *flexible;
        filterEvents(events, fixed, flexible);

        // Try to fit each flexible event
        for each(Event *e in flexible) {
            // Get available time slots from fixed event array relative to this event
            vector<TimeSlot> *timeSlots = timeSlots(fixed, e);

            // For each time slot I try to fit the events
            for (int j = 0; j<timeSlots->size(); j++) {
                
                long eDuration = (long)e->duration;                         // Event Duration
                long sDuration = timeSlots[j]->end - timeSlots[j]->start;   // Time slot duration

                if (eDuration > sDuration) {
                    // Can't fit so try another one
                    continue;
                }

                // We can try to know if it is reachable
                if (eventIsToday(e)) {
                    // Consider user latest reliable position
                    Event *prev = siblingTimeSlotEvent(c, timeSlots[j]);
                    if (prev == null) {
                        // no previous event, try user location
                        Coordinates *userPos = reliableUserPosition(u);
                        if (userPos == null) {
                            // No user position, try another time slot
                            continue;
                        }
                        else {
                            if (eventIsReachable(userPos, e)) {
                                // REACHABLE
                                insert(fixed, e);
                                remove(flexible, e);
                                break;
                            }
                            else {
                                // Try another time slot
                                continue;
                            }
                        }

                    }
                    else {
                        if (eventIsReachable(prev, e)) {
                            // REACHABLE
                            insert(fixed, e);
                            remove(flexible, e);
                            break;
                        }
                        else {
                            // Try another time slot
                            continue;
                        }
                    }
                }
                else {
                    // Don't consider last reliable user position

                    Event *prev = siblingTimeSlotEvent(c, timeSlots[j]);
                    if (prev == null) {
                        // no previous event try another time slot
                        continue;
                    }
                    else {
                        if (eventIsReachable(prev, e)) {
                            // REACHABLE
                            insert(fixed, e);
                            remove(flexible, e);
                            break;
                        }
                        else {
                            // Try another time slot
                            continue;
                        }
                    }
                }

            }
            

        }

        if (flexible->size() > 0) {
            notifyUnreachable(u, flexible);
            return null;
        }

        // Now we need to make sure that unscheduled and unfitted events are reachable
        
        for each(int i = 0; i<events->size(); i++) {
            if (i == events->size()-1) {
                // last one so exit
                break;
            }

            if (events[i]->routes == null || events[i]->suggested_start == null || events[i]->suggested_end == null) {
                // Unscheduled

                if (eventIsFirstOfDay(events[i], c)) {
                    if (eventIsToday(events[i])) {
                        // Try with user location

                        Coordinates *userPos = reliableUserPosition(u);
                        if (userPos == null) {
                            // No user position, unreachable then
                            notifyUnreachable(u, events[i]);
                            return null;
                        }
                        else {
                            if (eventIsReachable(userPos, events[i])) {
                                // REACHABLE
                                scheduled->push_back(event[i]);
                                continue;
                            }
                            else {
                                // Not Reachable
                                notifyUnreachable(u, events[i]);
                                return null;
                            }
                        }
                    }
                    else {
                        // Always reachable so go next
                        scheduled->push_back(event[i]);
                        continue;
                    }
                }
                else {
                    // Check if next event is reachable from this one

                    if (eventIsReachable(events[i+1], events[i])) {
                        // REACHABLE
                        scheduled->push_back(event[i+1]);
                        continue;
                    }
                    else {
                        // Not Reachable
                        notifyUnreachable(u, events[i+1]);
                        return null;
                    }
                }

                
            }
            else {
                // Already scheduled
                scheduled->push_back(e);
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

// ******** User

// Returns last reliable user position
Coordinates* reliableUserPosition(User *u);

// ******** Events

// Given a set of events returns whether these overlaps
bool overlap(vector<Event> *events);

// Given a set of events returns an array of overlapping events if they exist
vector<Event>* overlappingEvents(vector<Event> *events);

// Returns a set of Calendar's events between some dates ordered by startdate.
vector<Event>* getCalendarEventsInRange(Calendar *calendar, Date d1, Date d2);

// Returns Present / future events from a set of events
vector<Event>* nextEvents(vector<Event>*);

// Returns true if the event is today
bool eventIsToday(Event *e);

// Returns true if this event is scheduled as first of the day
bool eventIsFirstOfDay(Event *e, Calendar *c);

// Check if an event is reachable from specific coordinates and saves in it routes informations and sets suggested_start / suggested_end
bool eventIsReachable(Coordinates coords, Event *e);

// Check if an event e2 is reachable from previous event e1  and saves in it routes informations and sets suggested_start / suggested_end
bool eventIsReachable(Event *e1, Event *e2);

// Filters events to flexible and fixed and puts then in order of happening. For flexible events it orders them by their fitness function.
void filterEvents(vector<Event> *main, vector<Event> *fixed, vector<Event> *flexible);

// Removes travel data in an array of events, removing previously calculated routes and suggestions
void resetEvents(vector<Event> events);


// ******** TimeSlot

// Returns available time slots from a set of events relative to a single flexible event ordered from the smallest to the tallest
vector<TimeSlot> timeSlots(vector<Event> *events , Event *relative);

// Returns the event prior to a time slot
Event* siblingTimeSlotEvent(Calendar *c, TimeSlot *t);

// ******** Routes

// Returns time to reach event which is the mean value between all routes time
long routeTime(vector<Route> *routes);

// ******** Schedule
// Appends a schedule to an existing one
Schedule* appendSchedule(Schedule *s1, Schedule *s2);

// ******** Vector help
void insert(vector<Event> *e, Event *e);
void remove(vector<Event> *e, Event *e);


// ********* Notifications
// Sends back a notifications
void notifyOverlapping(User *u, vector<Event> *events);
void notifyUnreachable(User *u, vector<Event> *events);
void notifyUnreachable(User *u, Event* event);