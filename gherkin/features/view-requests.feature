#language: de

Funktionalität: Einladungs-Anforderungen anzeigen
	Um zu sehen, wieviele Einladungen angefordert sind
	möchte ich als Admin eine Auflistung der Anfragen haben
	damit ich einzelne Interessenten einladen kann
		
	Szenario: Der Admin lässt sich alle Anfragen anzeigen
		Angenommen sei, dass ich eine Einladung mit einer gültigen E-Mail "kontakt@foogoo.info" anfordere
		Und ich als Admin eingeloggt bin
		Wenn ich die Auflistung der Nutzer betrachte
		Dann sollte ich "christian@russ.de" in einer Auflistung sehen
		Und ich sollte "kontakt@foogoo.info" in einer Auflistung sehen
		Und der Zugang mit der E-Mail "kontakt@foogoo.info" sollte unbestätigt sein
		Und der Nutzer mit der E-Mail "kontakt@foogoo.info" sollte als inaktiv angezeigt werden
		
	Szenario: Nicht-Admins sollen keine Übersicht über die Anfragen haben
		Angenommen sei, dass ich eingeloggt bin
		Und ich user Rechte besitze
		Wenn ich die Auflistung der Nutzer betrachte
		Dann sollte die Nachricht eine Fehlermeldung sein