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

// Schedule function that checks the next hours, this can be called when user uploads his current position or the system calls it every 2 hours
void schedule(User u) {
    
}

// Schedule function that checks just the 12 hours before and after the event as parameter that has been created, modified or deleted
void schedule(User u, Event e) {
    
}

// Schedule an entire date interval, this can be called from the other schedule functions
void schedule(User u, Date d1, Date d2) {

}