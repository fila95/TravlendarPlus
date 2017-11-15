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

    double lat;
    double lng;

    // time
    unsigned long start;
    unsigned long end;
    int duration;
    
    bool[7] repetitions;
    bool[5] transports;

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

    Setting settings;

}



// Schedule function that checks the next hours, this can be called when user uploads his current position or the system calls it every 2 hours
void schedule(User *u) {
    
}

// Schedule function that checks just the 12 hours before and after the event as parameter that has been created, modified or deleted
void schedule(User *u, Event e) {
    
}

// Schedule an entire date interval, this can be called from the other schedule functions
void schedule(User *u, Date d1, Date d2) {

    // Check for each user's calendar overlapping and reachability
    for each(Calendar *c in u.calendars) {

        // Get all the events on the calendar between that dates
        vector<Event> *events = getCalendarEventsInRange(c, d1, d2);
    
        // Ensure events does not overlap
        if (overlap(events)) {
            vector<Event> *overlapping = overlappingEvents(events);
            notifyOverlapping(u, overlapping);
            return;
        }
    
        // Now we need 
        


    }


}


// Returns current timestamp
unsigned long now();

// Given a set of events returns whether these overlaps
bool overlap(vector<Event> *events);

// Given a set of events returns an array of overlapping events if they exist
vector<Event>* overlappingEvents(vector<Event> *events);

// Returns a set of Calendar's events between some dates ordered by startdate.
vector<Event>* getCalendarEventsInRange(Calendar *calendar, Date d1, Date d2);




// Sends back a notification that overlapping events exists.
void notifyOverlapping(User *u, vector<Event> *events);