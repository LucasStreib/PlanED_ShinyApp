Dieses Repository enthält das Software-Framework, die Input-Daten sowie den R-Code für eine interaktive Shiny-Webanwendung, die im Rahmen des DBU-Projekts 38150-01 entwickelt wurde:

## **PlanED – Entwicklung und Anwendung digitaler Planungswerkzeuge für ökologische Aufwertungsmaßnahmen von 'Eh da'-Flächen auf Landschaftsebene am Beispiel einer Modellregion**

Interaktive Shiny-Webanwendung zur Unterstüzung von Planungsprozessen zur ökologischen Aufwertung von 'Eh da'-Flächen (Identifikation, Analyse & Priorisierung) auf Landschaftsebene in einer hessischen Modellregion, bestehend aus den Städten Homberg (Ohm) und Kirtorf.

## Projektkontext

Aufgrund des Insektenrückgangs in Deutschland rücken verfügbare Flächen als zentrale Ressource für den Insektenschutz in den Fokus, da sie ein bislang wenig genutztes Potenzial zur gezielten Schaffung und Vernetzung von Lebensräumen auf Landschaftsebene bieten. Sogenannte 'Eh da'-Flächen – meist kommunale, wirtschaftlich und naturschutzfachlich ungenutzte Flächen – sind hierfür besonders geeignet, und wurden auf Basis amtlicher Geodaten für die Modellregion identifiziert.

Die entwickelte Webanwendung basiert auf dem Open-Source-Framework Shiny für die Programmiersprache R und hat ein modulares Design mit Textinhalten, interaktiven Karten und Tabellen. Sie integriert verschiedene R-Pakete (z. B. für WebGIS-Visualisierung) und stellt folgende Funktionen bereit:

- **Information:** Zentrale Plattform zur Bereitstellung fachlicher Inhalte, Informationen zum Projektverlauf  
- **Visualisierung:** Interaktive Karten (WebGIS) zu Darstellung fachlicher im Projekt verwendeten Geodaten
- **Analyse:** Planungswerkzeuge zur räumlichen Bewertung | Priorisierung von Potenzialflächen ('Eh da'-Flächen) für die ökologische Aufwertung über On-the-fly berechnete Netzwerke ('Luftlinien Distanz' oder 'Kosten Distanz' aus Landschaftsklassifikation)

Die Webanwendung wurde in der hessischen Modellregion erprobt, in der ausgewählte Maßnahmen umgesetzt und durch begleitende Erhebungen dokumentiert wurden. Der Quellcode ist Open Source und kann mit angepassten Eingangsdaten auf andere Kommunen oder Anwendungsfälle übertragen werden.

### A. SOFTWARE-FRAMEWORK

Die Webanwendung basiert auf dem Open-Source-Webframework *Shiny* für die Programmiersprache *R* und nutzt eine Vielzahl etablierter *R*-Pakete (u. a. für interaktive Kartendarstellung, z. B. *Leaflet*). Zur Sicherstellung reproduzierbarer Umgebungen wird das Paketmanagement mit *renv* eingesetzt, wodurch Abhängigkeiten und Paketversionen konsistent verwaltet werden können.

Das Hosting erfolgt containerbasiert über die OpenShift-Plattform des Landesbetriebs Daten und Information (LDI) Rheinland-Pfalz. 

### B. INPUT-DATEN

### C. R-CODE

-----

Für Anregungen oder weiterführende Informationen kontaktieren Sie bitte:

Dr. Lucas Streib \
Diplom-Umweltwissenschaftler 

&#9993; lucas.streib@dlr.rlp.de \
&#9990; +49 (0) 06321 671 443 

DIENSTLEISTUNGSZENTRUM LÄNDLICHER RAUM (DLR) RHEINHESSEN-NAHE-HUNSRÜCK \
Technische Zentralstelle - Gruppe Digitalisierung 

Zentrale Postanschrift: \
Postfach 573 \
55529 Bad Kreuznach 

Hausanschrift: \
67435 Neustadt \
Telefon: 06321 671-0 \
E-Mail: dlr-rnh@dlr.rlp.de \
Internet: http://www.dlr-rnh.rlp.de









